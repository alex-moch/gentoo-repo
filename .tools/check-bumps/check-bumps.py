#!/usr/bin/env python3
"""Report available version bumps across the whole overlay.

Default rule: inspect each package's own highest-version ebuild
(inherit line / SRC_URI) to infer where to check for a newer upstream
version -- no per-package table entry needed for the common cases
(PyPI via the pypi eclass, GitHub tag/release archives). `overrides.json`
holds only the genuine exceptions: packages with no upstream, packages
that need a different check than what auto-detection would infer, and
packages whose SRC_URI pins a commit rather than a tag.

Report only -- this does not touch any ebuild.
"""
import json
import os
import re
import sys
import urllib.error
import urllib.request
from collections import defaultdict

from portage.versions import pkgsplit, vercmp

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
OVERRIDES_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "overrides.json")

GITHUB_TOKEN = os.environ.get("GITHUB_TOKEN")
SKIP_CATEGORIES = {"acct-group", "acct-user"}  # never have an upstream to check, unless overridden

GITHUB_URL_RE = re.compile(
    r"github\.com/([\w.-]+)/([\w.-]+)/(?:archive|releases)/(?:download/[^/\s]+/|refs/tags/)?v?\$\{(?:PV|MY_PV|P)\}"
)

_HTTP_CACHE = {}


def http_json(url, headers=None):
    if url in _HTTP_CACHE:
        return _HTTP_CACHE[url]
    req = urllib.request.Request(url, headers=headers or {})
    with urllib.request.urlopen(req, timeout=20) as resp:
        data = json.load(resp)
    _HTTP_CACHE[url] = data
    return data


def http_text(url, headers=None):
    if url in _HTTP_CACHE:
        return _HTTP_CACHE[url]
    req = urllib.request.Request(url, headers=headers or {})
    with urllib.request.urlopen(req, timeout=20) as resp:
        data = resp.read().decode("utf-8", "replace")
    _HTTP_CACHE[url] = data
    return data


def github_headers():
    h = {"Accept": "application/vnd.github+json", "User-Agent": "check-bumps"}
    if GITHUB_TOKEN:
        h["Authorization"] = f"Bearer {GITHUB_TOKEN}"
    return h


def normalize(v, prefix=None, strip_dots=False):
    v = v.strip()
    if prefix and v.startswith(prefix + "-"):
        v = v[len(prefix) + 1 :]
    if len(v) > 1 and v[0] in "vV" and (v[1].isdigit()):
        v = v[1:]
    if strip_dots:
        v = v.replace(".", "")
    return v


def compare(current, latest, prefix=None, strip_dots=False):
    """Return ('same'|'bump'|'differs', current_norm, latest_norm)."""
    cur_n = normalize(current, prefix)
    lat_n = normalize(latest, prefix, strip_dots=strip_dots)
    if cur_n == lat_n:
        return "same", cur_n, lat_n
    result = vercmp(cur_n, lat_n)
    if result is None:
        return "differs", cur_n, lat_n
    return ("bump" if result < 0 else "differs"), cur_n, lat_n


# --- strategies -------------------------------------------------------

def strategy_pypi(name):
    data = http_json(f"https://pypi.org/pypi/{name}/json")
    return data["info"]["version"]


def strategy_github_release(repo):
    try:
        data = http_json(f"https://api.github.com/repos/{repo}/releases/latest", github_headers())
        return data["tag_name"]
    except urllib.error.HTTPError as e:
        if e.code != 404:
            raise
        tags = http_json(f"https://api.github.com/repos/{repo}/tags", github_headers())
        if not tags:
            raise RuntimeError("no releases or tags found")
        return tags[0]["name"]


def strategy_github_commit(repo):
    data = http_json(f"https://api.github.com/repos/{repo}/commits", github_headers())
    return data[0]["sha"]


def strategy_rubygems(name):
    data = http_json(f"https://rubygems.org/api/v1/versions/{name}/latest.json")
    return data["version"]


def strategy_apt_packages(url):
    text = http_text(url)
    versions = re.findall(r"^Version:\s*(\S+)", text, re.M)
    if not versions:
        raise RuntimeError("no Version: lines found")
    versions.sort(key=lambda v: v.split("."))
    best = versions[0]
    for v in versions[1:]:
        if vercmp(best, v) is not None and vercmp(best, v) < 0:
            best = v
    return best


# --- ebuild inspection --------------------------------------------------

def find_packages(root):
    """Yield (cat, pkg, pv, ebuild_path) for the highest non-live version of every package."""
    for cat in sorted(os.listdir(root)):
        cat_path = os.path.join(root, cat)
        if cat.startswith(".") or not os.path.isdir(cat_path) or cat in ("profiles", "metadata", "eclass"):
            continue
        for pkg in sorted(os.listdir(cat_path)):
            pkg_path = os.path.join(cat_path, pkg)
            if not os.path.isdir(pkg_path):
                continue
            best_pv, best_file = None, None
            for fname in os.listdir(pkg_path):
                if not fname.endswith(".ebuild"):
                    continue
                split = pkgsplit(fname[: -len(".ebuild")])
                if split is None:
                    continue
                _, pv, _ = split
                if pv == "9999":
                    continue  # live ebuild, nothing to bump-check
                if best_pv is None or (vercmp(pv, best_pv) or 0) > 0:
                    best_pv, best_file = pv, fname
            if best_file:
                yield cat, pkg, best_pv, os.path.join(pkg_path, best_file)


def detect_strategy(cat, pkg, ebuild_path):
    with open(ebuild_path) as f:
        text = f.read()

    inherit_lines = "\n".join(re.findall(r"^inherit\b.*$", text, re.M))
    src_uri_match = re.search(r'SRC_URI="(.*?)"', text, re.S)
    src_uri = src_uri_match.group(1) if src_uri_match else ""
    homepage_match = re.search(r'HOMEPAGE="(.*?)"', text, re.S)
    homepage = homepage_match.group(1) if homepage_match else ""

    # Ebuilds commonly spell the upstream repo/project name via ${PN} or a
    # local ${MY_PN} override rather than a literal string -- expand both
    # so the github-url regex can see the real org/repo.
    my_pn = re.search(r'^MY_PN="([^"]+)"', text, re.M)
    src_uri = src_uri.replace("${PN}", pkg).replace("${MY_PN}", my_pn.group(1) if my_pn else pkg)
    homepage = homepage.replace("${PN}", pkg).replace("${MY_PN}", my_pn.group(1) if my_pn else pkg)

    commit_var = re.search(r"^(?:COMMIT|HASH_COMMIT)=\"([0-9a-fA-F]+)\"", text, re.M)
    if commit_var and commit_var.group(1) in src_uri:
        gh = re.search(r"github\.com/([\w.-]+)/([\w.-]+)/archive/", src_uri)
        if gh:
            return {"strategy": "github-commit", "repo": f"{gh.group(1)}/{gh.group(2)}", "commit": commit_var.group(1)}

    if re.search(r"\bpypi\b", inherit_lines):
        pypi_pn = re.search(r'^PYPI_PN="([^"]+)"', text, re.M)
        return {"strategy": "pypi", "name": pypi_pn.group(1) if pypi_pn else pkg}

    gh = GITHUB_URL_RE.search(src_uri) or GITHUB_URL_RE.search(homepage)
    if gh:
        return {"strategy": "github-release", "repo": f"{gh.group(1)}/{gh.group(2)}"}

    if re.search(r"\bruby-fakegem\b", inherit_lines) and "github.com" not in src_uri:
        return {"strategy": "rubygems", "name": pkg}

    return {"strategy": "unknown"}


def ebuild_commit(ebuild_path):
    """Pull the real pinned commit out of an ebuild, for github-commit strategies
    (whether auto-detected or set via an overrides.json entry -- the override only
    needs to name the repo, not duplicate a commit hash that would go stale)."""
    with open(ebuild_path) as f:
        text = f.read()
    m = re.search(r"^(?:COMMIT|HASH_COMMIT)=\"([0-9a-fA-F]+)\"", text, re.M)
    return m.group(1) if m else None


def run_strategy(spec, ebuild_path):
    kind = spec["strategy"]
    if kind == "pypi":
        return strategy_pypi(spec["name"])
    if kind == "github-release":
        return strategy_github_release(spec["repo"])
    if kind == "github-commit":
        return strategy_github_commit(spec["repo"])
    if kind == "rubygems":
        return strategy_rubygems(spec["name"])
    if kind == "apt-packages":
        return strategy_apt_packages(spec["url"])
    raise RuntimeError(f"no handler for strategy {kind!r}")


def main():
    with open(OVERRIDES_PATH) as f:
        overrides = {k: v for k, v in json.load(f).items() if not k.startswith("_")}

    results = defaultdict(list)

    for cat, pkg, pv, ebuild_path in find_packages(REPO_ROOT):
        key = f"{cat}/{pkg}"
        override = overrides.get(key)

        if override and "skip" in override:
            results["skip"].append((key, pv, None, override["skip"]))
            continue

        spec = override if override else detect_strategy(cat, pkg, ebuild_path)
        if cat in SKIP_CATEGORIES and not override:
            results["skip"].append((key, pv, None, "no upstream (unconfirmed -- add to overrides.json)"))
            continue

        if spec["strategy"] == "unknown":
            results["unknown"].append((key, pv, None, "no strategy detected -- add an overrides.json entry"))
            continue

        try:
            latest = run_strategy(spec, ebuild_path)
        except Exception as e:  # network/API errors of any kind
            results["error"].append((key, pv, None, f"{spec['strategy']}: {e}"))
            continue

        if spec["strategy"] == "github-commit":
            real_current = spec.get("commit") or ebuild_commit(ebuild_path)
            if real_current and (latest.startswith(real_current) or real_current.startswith(latest)):
                results["up-to-date"].append((key, pv, pv, spec["strategy"]))
            else:
                results["bump"].append((key, (real_current or pv)[:12], latest[:12], spec["strategy"]))
            continue

        status, cur_n, lat_n = compare(
            pv, latest, prefix=spec.get("strip_prefix", pkg), strip_dots=spec.get("strip_dots", False)
        )
        if status == "same":
            results["up-to-date"].append((key, pv, lat_n, spec["strategy"]))
        elif status == "bump":
            results["bump"].append((key, pv, lat_n, spec["strategy"]))
        else:
            results["differs"].append((key, pv, lat_n, f"{spec['strategy']} -- versions not directly comparable, check by hand"))

    order = [
        ("bump", "BUMP AVAILABLE"),
        ("differs", "DIFFERS (needs a human look)"),
        ("error", "ERROR (network/API failure)"),
        ("unknown", "UNKNOWN (no check strategy)"),
        ("skip", "SKIPPED"),
        ("up-to-date", "UP TO DATE"),
    ]
    total = sum(len(v) for v in results.values())
    for key, title in order:
        rows = sorted(results[key])
        if not rows:
            continue
        print(f"\n=== {title} ({len(rows)}) ===")
        for pkg_key, cur, latest, note in rows:
            if latest:
                print(f"  {pkg_key:<55} {cur} -> {latest}")
            else:
                print(f"  {pkg_key:<55} {cur:<20} {note}")
            if latest and key in ("differs",):
                print(f"      {note}")

    print(f"\n{total} packages checked.")
    if not GITHUB_TOKEN:
        print("Note: GITHUB_TOKEN not set -- unauthenticated GitHub API calls are capped at 60/hour.")


if __name__ == "__main__":
    sys.exit(main())
