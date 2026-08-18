# Conventions

## Commit messages

- Sentence case, not title case.
- Subject line ends with a full stop.
- Backticks around file and directory names.
- Body with a brief description before trailers.
- Always include `Signed-off-by: Alexander Moch <mail@alexmoch.com>`
- Include `Co-authored-by: Claude <model> <noreply@anthropic.com>` when Claude wrote substantive code or made design decisions. Include the model name (e.g. `Claude Opus 4.7`, `Claude Sonnet 4.6`) so commits stay attributable to a specific model generation. Skip for routine version bumps, mechanical refactors, and pure data entry (e.g. filling in `metadata.xml` from user-provided facts).

## Workflow

- Never run `git commit`. The user performs all commits; just provide
  the commit message.
- `pkgdev manifest` requires `sudo` — `/var/cache/distfiles/` is owned
  by `root:portage` and the user is not in the `portage` group.
- Use `git mv` when renaming ebuild files (e.g. for version bumps) so
  the rename is preserved in history.
- Run `pkgcheck scan` after editing ebuilds or metadata to catch
  policy issues early.
- One commit per logical change. Don't bundle unrelated cleanups
  into a single commit, and don't pre-stage when the user might
  want to split.
- `pkgcheck` passing does not mean a package works. For version
  bumps — especially pinned ones that look like a pure rename — do a
  runtime smoke test (`emerge` then actually launch the program)
  before calling it done. Import-time dependency breakage is invisible
  to `pkgcheck`.
- For non-trivial tasks, ask focused clarifying questions before
  making cross-cutting decisions rather than guessing and
  proceeding.

## Ebuilds

- Follow the [Gentoo Development Guide](https://devmanual.gentoo.org/) when in doubt on style.
- For new packages, check the main Gentoo tree and public overlays first; use existing ebuilds as boilerplate where useful.
- When working on a package, check whether a newer upstream release is available.
- Add `metadata.xml` if non-existent.

## metadata.xml

- Maintainer email is `gentoo@alexmoch.com` (intentionally different
  from the commit `Signed-off-by` which uses `mail@alexmoch.com`).
- For forked ebuilds, replace the upstream maintainer with the local
  one rather than coexist.
- `<pkg>` only accepts Gentoo package atoms (e.g.
  `app-emulation/vmware-modules`) — never put arbitrary `org/repo`
  strings inside `<pkg>`; `pkgcheck` will flag them.
- `<code>` is not a valid element. Use plain text or backticks for
  inline tokens in flag descriptions.
- Authoritative element/attribute list lives in the DTD; fetch with
  `curl https://www.gentoo.org/dtd/metadata.dtd` to check what's
  allowed before guessing.

## Indentation

- Spaces by default.
- Tabs where conventionally required (Makefiles, ebuilds — Gentoo tree prefers tabs).

# Package provenance

Reference for where each package in this overlay originated. Use these
when looking up upstream changes or comparing against the source ebuilds.

## Source overlays

| Overlay | URL |
|---|---|
| Gentoo (official) | https://codeberg.org/gentoo/gentoo (mirror: https://github.com/gentoo-mirror/gentoo) |
| GURU | https://gitweb.gentoo.org/repo/proj/guru.git/ |
| Pentoo | https://github.com/pentoo/pentoo-overlay/ |
| nest (SpiderX) | https://github.com/SpiderX/portage-overlay |
| pg_overlay | https://gitlab.com/Perfect_Gentleman/PG_Overlay |
| pf4public | https://github.com/PF4Public/gentoo-overlay |

## Per-package origin

| Package | Origin | Notes |
|---|---|---|
| `acct-group/lemonade` | local | Created here, mirrors `acct-group/ollama` |
| `acct-group/ollama` | GURU | Forked, maintainer reassigned |
| `acct-group/vmware` | local | Created here |
| `acct-user/lemonade` | local | Created here, mirrors `acct-user/ollama`; home `/var/lib/lemonade` |
| `acct-user/ollama` | GURU | Forked, maintainer reassigned |
| `app-forensics/sleuthkit` | Gentoo (official) | Forked, maintainer reassigned. Carries local patches: refreshed `exclude-usr-local`, plus `gnuconfig_update` on the bundled libewf so `USE=ewf` builds on `aarch64`/`musl` |
| `app-emulation/vmware-modules` | local | Tracks https://github.com/alex-moch/vmware-modules |
| `app-emulation/vmware-workstation` | hybrid: nest + pg_overlay + pf4public | Heavy local rework |
| `app-misc/claude-desktop` | local | Written from scratch — no upstream ebuild reference. Repackages Anthropic's official `.deb` (a prebuilt Electron bundle) into `/opt`. `RDEPEND` derived from the shipped binaries' ELF `NEEDED` set; the Debian maintainer scripts (AppArmor userns profile, apt-repo registration) are intentionally dropped as Debian-specific. Docs at https://code.claude.com/docs/en/desktop-linux. The 1.24012.11 → 1.32352.1 bump (~90 upstream releases) dropped two RDEPEND entries after a full re-scan (`scanelf -qn` across every ELF/`.node` file in the bundle, not just the main binary — the earlier RDEPEND was seeded from a narrower scan): `x11-libs/libXtst` (global shortcuts moved to the `org.freedesktop.portal.GlobalShortcuts` D-Bus portal, already covered by `sys-apps/xdg-desktop-portal`) and `sys-apps/util-linux` (Chromium's own `base::Uuid` replaced the external `libuuid` dependency). Neither soname appears anywhere in the bundle any more — confirmed with a repo-wide `grep`, not just the top-level `scanelf` output |
| `dev-debug/pwndbg` | Gentoo (official) | Version-pinned fork, now **ahead** of the official tree and carrying local patches (capstone de-vendor via `src_prepare`, `niche-elf` dep, `pycparser` floor). No longer byte-identical to upstream — do not assume a clean diff/rebase |
| `dev-libs/capstone` | local | Forked from Gentoo's own `capstone-6.0.0_alpha7.ebuild` (used as boilerplate, per the "check the main Gentoo tree first" convention) because `dev-debug/pwndbg`'s capstone floor ran ahead of what Gentoo packages — the 2026.07.29 pwndbg bump needed `CS_MODE_RISCV_ZBA`/`ZBB`/`ZBS` and `CS_OPT_SYNTAX_NO_ALIAS_TEXT_COMPRESSED`, symbols only present from capstone `6.0.0-Alpha8` onward, and Gentoo's tree topped out at `alpha7` (confirmed against the live upstream tree, not a stale local mirror). Pinned to `alpha9` to match `capstone6pwndbg`'s own upstream pin. Carries the same `capstone-werror.patch` Gentoo's own ebuild uses (applies via fuzzy match on both `alpha7` and `alpha9` — `CMakeLists.txt`'s relevant region is byte-identical between the two, so the fuzz isn't a new risk introduced by this fork). Drop this fork once Gentoo ships `alpha8`+ and re-point `dev-debug/pwndbg`'s RDEPEND back at the official package |
| `dev-python/niche-elf` | local | Created here from pwndbg's PyPI dependency (upstream `github.com/pwndbg/niche-elf`); pure-Python |
| `dev-python/chromadb` | local | Written from scratch — upstream never publishes an sdist for this package. Installed via the real prebuilt manylinux wheel instead of vendoring its ~1020-crate Rust/PyO3 workspace (`DISTUTILS_USE_PEP517=no`, custom `python_compile()` calling `distutils_wheel_install()`), patterned after `dev-util/semgrep-core-bin`. The compiled `.so` only links `libc`/`libm`/`libpthread`/`libdl`/`ld-linux` (verified via `scanelf -qn`) — no hidden native RDEPEND risk from skipping the source build |
| `dev-python/face` | Pentoo | Forked, maintainer reassigned. Pulled in as a `dev-python/glom` sub-dependency |
| `dev-python/glom` | Pentoo | Forked, maintainer reassigned. Pentoo's copy was the only source for a `dev-python/semgrep` dependency |
| `dev-python/httpx-sse` | Pentoo | Forked, maintainer reassigned. Pulled in as a `dev-python/mcp` sub-dependency |
| `dev-python/langflow-base` | local | Written from scratch — Langflow's Python backend (API/CLI only; the bundled npm/React frontend and the root `langflow` PyPI package are out of scope). No sdist upstream — same prebuilt-wheel-install mechanism as `dev-python/chromadb`. `IUSE="anthropic google-genai ollama openai weaviate"` gates optional LangChain providers that don't appear in upstream's own `requires_dist` at all (their provenance is the running component registry, not dependency metadata — grepped from the wheel's component source, not derived from a pyproject extra); `weaviate` is real-upstream-mandatory as of `0.11.0` but stays default-off since `weaviate-client` still pins `grpcio<1.80.0` and this tree only carries `1.80.0+` |
| `dev-python/langflow-sdk` | local | Written from scratch — thin Python client for the Langflow REST API. Wheel-only upstream (every release, including pre-releases), same install mechanism as `dev-python/chromadb` |
| `dev-python/lfx` | local | Written from scratch — Langflow's executor/CLI, `langflow-base`'s own dependency. Wheel-only upstream, same install mechanism as `dev-python/chromadb` |
| `dev-python/mcp` | Pentoo | Forked, maintainer reassigned, version-bumped (1.14.0 → 1.29.0). Bumped past `dev-python/semgrep`'s exact `mcp==1.23.3` pin to fix CVE-2026-52869 (session-hijacking-class auth bypass, GHSA-jpw9-pfvf-9f58) — the fix was backported to the 1.x line (tagged `[v1.x]` upstream) rather than only landing in the `2.0.0` rewrite, so `semgrep`'s RDEPEND was loosened to `>=1.27.2,<2` instead of mirroring the exact pin. See "semgrep bump procedure" below |
| `dev-python/opentelemetry-{proto,exporter-otlp-proto-common,exporter-otlp-proto-http,instrumentation,instrumentation-requests,instrumentation-threading,util-http}` | local | Created here — not yet packaged in Gentoo or GURU. `proto`/`exporter-otlp-proto-{common,http}` track the same `opentelemetry-python` monorepo tag as the tree's existing `opentelemetry-api`/`sdk`/`semantic-conventions` (currently `1.43.0`); `instrumentation`/`instrumentation-{requests,threading}`/`util-http` track the sibling `opentelemetry-python-contrib` repo (currently `0.64b0`, Gentoo-versioned `0.64_beta0`). See "OpenTelemetry paired-tag resolution" below before bumping any of these |
| `dev-python/semgrep` | Pentoo | Forked, maintainer reassigned, heavily version-bumped (1.75.0 → 1.171.0, ~2 years/95 releases). See "semgrep bump procedure" below |
| `dev-python/sse-starlette` | Pentoo | Forked, maintainer reassigned. Pulled in as a `dev-python/mcp` sub-dependency |
| `dev-util/Tensile` | Gentoo (official) | Temporary local hold — do not update; remove once the official tree carries a sufficient version |
| `dev-util/semgrep-core-bin` | Pentoo | Forked, maintainer reassigned, heavily reworked. Upstream's wheel now bundles `semgrep-core`'s native shared-lib dependencies (`bin/libs/`) instead of linking the host's — install layout changed from a flat `dobin` to a private `/usr/libexec/semgrep-core-bin/` dir + symlink. See "semgrep bump procedure" below |
| `dev-vcs/gitleaks` | Pentoo | Forked, maintainer reassigned |
| `net-firewall/littlesnitch` | local | Written from scratch — no upstream ebuild reference; product page at https://obdev.at/products/littlesnitch-linux/index.html |
| `net-misc/onedrive` | Gentoo (official) | Forked, maintainer reassigned, version-bumped ahead of the official tree (2.5.10 → 2.5.11 — the official tree hadn't packaged it as of the fork). No local patches: diffed `configure.ac`/`Makefile.in`/`config` between the two tags before bumping — same `curl`/`sqlite3`/`dbus`/optional-`libnotify` dependency set, the new `src/localAuth.d` (GUI OAuth loopback listener, a 2.5.11 feature) only uses Phobos stdlib, and the new `contrib/images/onedrive-notifications.svg` installs via upstream's existing `Makefile.in` icon rule gated on the same `NOTIFICATIONS` flag the ebuild's `libnotify` USE already wires up |
| `sci-libs/onnxruntime` | GURU | Forked, maintainer reassigned, now meaningfully diverged from the GURU copy — 4 local patches (`relax-the-dependency-on-flatbuffers`, `no-werror`, `prevent-generation-of-PIE`, `use-system-libraries`). The `use-system-libraries` patch needs re-verifying on every bump, not just reapplying: a 1.28.0 bump found one hunk broken by an upstream-inserted Windows ARM64/ARM64EC branch that shifted context enough for `patch --fuzz` to silently match the *wrong* `FIND_PACKAGE_ARGS NAMES cpuinfo` occurrence (a Windows-only branch this tree never builds) instead of the Linux one it's meant to target — regenerated fresh against the new source and confirmed zero-fuzz apply rather than trust the fuzzy match. `EIGEN_COMMIT` is a separate pin (`cmake/deps.txt`'s `eigen` entry) that doesn't necessarily move between bumps — check before assuming it needs updating |
| `sci-ml/lemonade-desktop` | local | Written from scratch — the native Tauri/WebKitGTK desktop client (`src/app` in the same monorepo as `sci-ml/lemonade-server`, a thin WebView pointed at it; doesn't bundle the server). Uses `cargo.eclass` with a real, fully-generated `CRATES` list (~590 entries, parsed from `src-tauri/Cargo.lock`) for fully offline/hermetic Rust vendoring — unlike the npm side, crates.io permanently hosts every published version at a fixed URL, so this needed no self-hosting, just the generated list. The npm side (`src/app`'s own React/webpack frontend, separate from the server's) still needs `RESTRICT="network-sandbox"` same as `lemonade-server`'s `USE=webapp`. `LICENSE` is the union of every vendored crate's own declared license (scanned from each fetched `.crate`'s `Cargo.toml`, not guessed) plus Apache-2.0 for the app itself. See "Lemonade bump procedure" below |
| `sci-ml/lemonade-server` | local | Written from scratch — no Gentoo/GURU ebuild exists upstream; used Arch's official `lemonade` PKGBUILD as boilerplate. Builds only `lemond`/`lemonade` (server + CLI); the Tauri desktop app is `sci-ml/lemonade-desktop`, a separate package. Carried two local patches through 11.5.1 (a `find_package(CONFIG)` fallback for `dev-cpp/cpp-httplib`, since Gentoo ships a CMake package config rather than a `.pc` file; a `pkg_search_module` fix for `mbedcrypto`, since Gentoo's `net-libs/mbedtls` slots it as `mbedcrypto-3`). As of 11.5.2, upstream rewrote httplib detection into its own `cmake/DetectSystemHttplib.cmake` with a native `find_package(httplib CONFIG)` fallback — functionally the same fix — so the httplib patch was dropped entirely; only the mbedcrypto-slot patch remains, re-targeted at the root `CMakeLists.txt` (upstream moved that whole probe there from `src/cpp/cli/CMakeLists.txt` in the same release). The 11.5.2 → 11.6.0 bump reconfirmed both: `cmake/DetectSystemHttplib.cmake` is byte-identical, and the mbedtls probe stayed in the root `CMakeLists.txt` (same content, ~72 lines further down) — the existing patch applies with zero fuzz, just a rename. `USE=webapp` (default on) gates the bundled web UI, which needs `net-libs/nodejs[npm]` and `RESTRICT="network-sandbox"` — Gentoo has no `cargo.eclass` equivalent for vendoring npm deps offline. See "Lemonade bump procedure" below |
| `sci-ml/ollama` | GURU | Forked, maintainer reassigned, refactored |

### VMware Workstation version encoding

The ebuild's `PV` encodes the marketing "H2" into field 2 (e.g.
`25.2.1.25219725`) so `ver_cut 2` directly yields the half number for
`MY_RELEASE="${MY_YEAR}H${MY_HALF}"`. VMware itself reports the same
build as `25.0.1.25219725` in the About dialog and in Broadcom CDS
metadata — both refer to the same release (25H2u1, build 25219725).

The overlay convention follows the inherited
nest / pg_overlay / pf4public encoding rather than VMware's canonical
form so that the bundle filename can be reconstructed from `PV`
alone. If you ever switch to canonical, the `MY_HALF` derivation has
to be hardcoded or table-driven instead of `ver_cut`.

## Upstream version checks

Endpoints to query for the latest upstream version. Fetch these directly
with `curl` rather than scraping vendor product pages. For GitHub-hosted
projects the JSON response's `tag_name` field is the latest stable
release (excluding pre-releases).

For anything not listed below — which is most of the overlay, including
the ~120 straightforward `pypi`-eclass `dev-python` packages pulled in for
Langflow — run `.tools/check-bumps/check-bumps.py` instead of hand-deriving
a check. It auto-detects a strategy per package from the ebuild itself
(`inherit pypi` → PyPI JSON API; a GitHub-hosted `SRC_URI` → GitHub
releases/tags API; `ruby-fakegem` with no `SRC_URI` → rubygems.org) and only
needs a `.tools/check-bumps/overrides.json` entry for genuine exceptions.
It's report-only — it tells you what's newer, not whether bumping is safe;
every flagged bump still needs its real transitive pin checked before
applying (see `.tools/check-bumps/overrides.json` for logged examples of
where the naive "latest on PyPI" answer was wrong).

| Package | URL | Notes |
|---|---|---|
| `app-emulation/vmware-modules` | `https://api.github.com/repos/alex-moch/vmware-modules/commits` | Tracks `master`; ebuild's `COMMIT=` should match the first `sha` in the JSON response |
| `app-emulation/vmware-workstation` | `https://softwareupdate.broadcom.com/cds/vmw-desktop/info-only/ws-linux/8.0.0/metadata.xml.gz` | See discovery chain below |
| `app-forensics/sleuthkit` | `https://api.github.com/repos/sleuthkit/sleuthkit/releases/latest` | Tag format `sleuthkit-X.Y.Z`; ebuild version is the `X.Y.Z` part. On bump, re-check `tsk/Makefile.am`'s `-version-info` first field for the `SLOT` subslot |
| `app-misc/claude-desktop` | `https://downloads.claude.ai/claude-desktop/apt/stable/dists/stable/main/binary-amd64/Packages` | No releases feed — parse the apt `Packages` index. Latest: `curl -fsSL <url> \| awk '/^Version:/{print $2}' \| sort -V \| tail -1`. Distfile is `claude-desktop_${PV}_${arch}.deb` under `.../pool/main/c/claude-desktop/`; the `.deb`'s own `SHA256` is in the same `Packages` block. Since it's a binary repackage, on bump re-scan the bundle's ELF `NEEDED` sonames (`scanelf -qn`) for new library deps before trusting the old `RDEPEND` |
| `dev-debug/pwndbg` | `https://api.github.com/repos/pwndbg/pwndbg/releases/latest` | Tag format `YYYY.MM.DD`; ebuild version drops the dots. See bump procedure below |
| `dev-libs/capstone` | `https://api.github.com/repos/capstone-engine/capstone/tags` | Only needs bumping when `dev-debug/pwndbg`'s `capstone6pwndbg` pin moves past what this fork provides, or once Gentoo's own tree catches up (check `https://api.github.com/repos/gentoo-mirror/gentoo/contents/dev-libs/capstone` — if it now has an ebuild at or past this fork's version, drop the fork and revert pwndbg's RDEPEND to the official package) |
| `dev-python/niche-elf` | (follows pwndbg) | Version is dictated by pwndbg's `pyproject.toml` pin, not bumped independently |
| `dev-python/mcp` | `https://pypi.org/pypi/mcp/json` | `info.version` is latest. No longer tied to `dev-python/semgrep`'s pin — bumps independently since CVE-2026-52869 forced `semgrep`'s RDEPEND to loosen instead (see provenance table) |
| `dev-python/opentelemetry-*` (see provenance table) | `https://api.github.com/repos/open-telemetry/opentelemetry-python/releases/latest` and `.../opentelemetry-python-contrib/releases/latest` | Only needs bumping when `dev-python/semgrep`'s `opentelemetry-*` floors move. See "OpenTelemetry paired-tag resolution" below |
| `dev-python/semgrep` | `https://api.github.com/repos/semgrep/semgrep/releases/latest` | Tag prefixed with `v`. See "semgrep bump procedure" below before touching this or `dev-util/semgrep-core-bin` |
| `dev-util/semgrep-core-bin` | (follows `dev-python/semgrep`) | Always bump in lockstep with `dev-python/semgrep` — same `PV` |
| `dev-vcs/gitleaks` | `https://api.github.com/repos/gitleaks/gitleaks/releases/latest` | Tag prefixed with `v` |
| `net-firewall/littlesnitch` | `https://obdev.at/products/littlesnitch-linux/download.html` | Parse the download URLs in the page (e.g. `littlesnitch-1.0.5-1-x86_64.pkg.tar.zst`); no machine-readable feed |
| `net-misc/onedrive` | `https://api.github.com/repos/abraunegg/onedrive/releases/latest` | Tag prefixed with `v`. `.tools/check-bumps` needs a `github-release` override for this one — `SRC_URI` uses a `codeload.github.com/OWNER/REPO/tar.gz/v${PV}` URL, and the script's github-URL regex only recognizes `.../archive/...` and `.../releases/...` paths, not codeload's own scheme. Written in D (GDC); before trusting a bump, diff `configure.ac` for new `PKG_CHECK_MODULES` probes and grep new/changed `src/*.d` files for imports outside Phobos stdlib — either would mean a new `RDEPEND` |
| `sci-libs/onnxruntime` | `https://api.github.com/repos/microsoft/onnxruntime/releases/latest` | Tag prefixed with `v`. Not a pure rename even when the ebuild looks unchanged — re-verify the 4 local patches still apply (check for zero-fuzz, don't trust a fuzzy `patch --fuzz` match blindly; see provenance table for a real instance of `patch` silently matching the wrong hunk) and re-check `cmake/deps.txt`'s `eigen` entry against the ebuild's `EIGEN_COMMIT` before assuming it moved |
| `sci-ml/lemonade-desktop` | (follows `sci-ml/lemonade-server`) | Always bump in lockstep with `sci-ml/lemonade-server` — same `PV`, same monorepo tag. See "Lemonade bump procedure" below — the `CRATES` list needs fully regenerating from the new tag's `src-tauri/Cargo.lock`, not hand-edited |
| `sci-ml/lemonade-server` | `https://api.github.com/repos/lemonade-sdk/lemonade/releases/latest` | Tag prefixed with `v`. See "Lemonade bump procedure" below before touching this — the local patch(es) (one as of 11.5.2, was two through 11.5.1) and `USE=webapp` wiring need re-verifying, not just the version string |
| `sci-ml/ollama` | `https://api.github.com/repos/ollama/ollama/releases/latest` | Tag prefixed with `v`; check `https://api.github.com/repos/ollama/ollama/releases` (without `/latest`) to also see pre-releases |

`acct-group/*` and `acct-user/*` packages have no upstream — they are
local system-account definitions and are version-bumped only when the
account schema needs to change.

### pwndbg bump procedure

A pwndbg bump is **not** a pure ebuild rename, even when the ebuild
looks unchanged. Upstream pins its Python dependencies in
`pyproject.toml`, and those shift between releases — this is what
breaks at runtime (invisible to `pkgcheck`):

- **`capstone6pwndbg`** — upstream vendors a forked capstone and imports
  from that module name. The ebuild's `src_prepare` rewrites those
  imports to the system `dev-libs/capstone` (`s/capstone6pwndbg/capstone/`).
  A prior bump also needed a renamed-constant rewrite (`CS_MODE_RISCVC` →
  `CS_MODE_RISCV_C`); the 2026.07.29 bump found upstream had renamed the
  import itself, making that specific sed a no-op, so it was dropped —
  don't assume the sed rules are stable across bumps, re-derive them from
  a real diff each time. More importantly: **new capstone symbols missing
  from Gentoo's capstone package is a real, recurring failure mode, not a
  hypothetical.** The 2026.07.29 bump needed `CS_MODE_RISCV_ZBA`/`ZBB`/`ZBS`
  and `CS_OPT_SYNTAX_NO_ALIAS_TEXT_COMPRESSED` (only in capstone
  `6.0.0-Alpha8`+), but Gentoo's tree topped out at `alpha7` — this wasn't
  caught by `pkgcheck` or even a shallow smoke test (`--batch -ex quit`
  ran fine; only exercising `context`/`disassemble` against a real running
  process hit the `NameError`). It required forking `dev-libs/capstone`
  into this overlay (see provenance table) to unblock. On every bump:
  don't just diff import lines — grep the *entire* new source tree for
  `from capstone6pwndbg` and every `CS_*`/`X86_INS_*`/`RISCV_INS_*` symbol
  it references, then check each one exists in the capstone version
  actually available (Gentoo's tree, or this overlay's `capstone` fork if
  one is currently in place) before trusting a clean build.
- **`niche-elf`** — separate `dev-python/niche-elf` package; keep its
  version matching pwndbg's pin.
- **`pycparser`** and other floors — diff the `pyproject.toml`
  `dependencies` list against the ebuild's `RDEPEND` and update bounds.

On every bump: fetch the source at the pinned tag, `grep -r capstone6pwndbg`
and diff `pyproject.toml`, then runtime smoke-test (`emerge` + launch —
and actually drive a breakpoint + `context`/`disassemble` against a real
binary, not just `--batch -ex quit`; the capstone symbol gap above only
surfaced under real disassembly, not at import time).

### semgrep bump procedure

`dev-python/semgrep` and `dev-util/semgrep-core-bin` always bump together
(same `PV`) and are more than a version-number swap:

- **`semgrep-core-bin`'s wheel URL is platform-tagged**, not the old
  universal `none-any` wheel. Construct `SRC_URI` with
  `pypi_wheel_url --unpack semgrep ${PV} "${PY_TAG}" "none-manylinux_2_34_x86_64"`
  (verify `PY_TAG` — the `cp3XX.py3XX` list — still matches by checking
  `https://pypi.org/pypi/semgrep/${PV}/json`'s `urls[]`). The eclass's
  pseudo-tag URL relies on a PyPI redirect; confirm with
  `curl -sI <constructed URL>` before trusting the Manifest fetch.
- **The wheel bundles `semgrep-core`'s shared-lib dependencies**
  (`purelib/semgrep/bin/libs/*.so`, ~30MB) rather than linking the host's.
  Several sonames (`libtree-sitter.so.0.22`, `libunwind.so.8` as of
  1.170.0) don't match what this system's own packages provide — don't
  try to relink against system libs without re-verifying every soname
  first. Install the binary and `libs/` together under a private
  `/usr/libexec/semgrep-core-bin/` dir with a `/usr/bin/semgrep-core`
  symlink, preserving the binary's `$ORIGIN/libs` RUNPATH.
- **`RESTRICT="strip"` is required**, not optional. Portage's default
  `prepstrip` re-strips this already-built OCaml binary, and doing so
  corrupts its ELF version-info sections badly enough that `ld.so` throws
  spurious `no version information available` / `undefined symbol: ,
  version` errors — but only on some `semgrep-core` code paths (`-rpc`
  mode, the `osemgrep` CLI dispatch), not on the trivial ones (`-version`
  worked fine even stripped), so a shallow `--version` smoke test can miss
  this entirely. Test an actual scan (`semgrep scan --config p/python
  <dir>`), not just `--version`.
- **`dev-python/mcp` is an exact pin** (`mcp==X.Y.Z` in semgrep's
  `pyproject.toml`) — check it on every bump and re-bump `dev-python/mcp`
  in lockstep if it moved. As of `mcp-1.29.0` this overlay deliberately does
  *not* mirror the exact pin (semgrep's real pin is still `mcp==1.23.3`, a
  CVE fix forced `mcp` ahead of it, see provenance table) — if semgrep's own
  pin ever moves past `1.29.0`, re-evaluate whether the RDEPEND should go
  back to an exact pin or stay loosened.
- **`dev-python/wcmatch` is pinned `~=8.3` upstream** but this overlay's
  tree only carries `10.x`/`11.0` (a two-major-version gap) — the RDEPEND
  uses a loosened `>=8.3` floor since no `8.x` ebuild exists here. This is
  an unverified compatibility risk, not a confirmed-safe relaxation;
  watch for glob/path-matching regressions in scan behavior.
- **Whole stack sits at `~amd64`, not `amd64`**, because the OTel
  packages this pulls in (`dev-python/opentelemetry-api`/`sdk` in the
  `gentoo` tree, and this overlay's own `opentelemetry-*` forks) are
  `~amd64`-only upstream — a stable `dev-python/semgrep` depending on an
  unstable OTel chain is exactly the `NonsolvableDepsInStable` violation
  `pkgcheck` flags. Don't reflexively mark semgrep `amd64` stable without
  first confirming Gentoo has stabilized the OTel chain.

On every bump: diff `pyproject.toml`'s `dependencies` against the
ebuild's `RDEPEND`, re-check the wheel's `bin/libs/` soname list against
`readelf -d`, then runtime smoke-test with a real scan, not just
`--version`.

### OpenTelemetry paired-tag resolution

`dev-python/opentelemetry-instrumentation-{requests,threading}` and
`opentelemetry-exporter-otlp-proto-http` (both pulled in by
`dev-python/semgrep`) span two separate upstream repos with independent
version schemes, and this overlay's existing `opentelemetry-api`/`sdk`/
`semantic-conventions` ebuilds already sidestep that by using the
`opentelemetry-python` monorepo's git tag as the Gentoo `PV` (e.g.
`1.43.0`) even though some subpackages (like `semantic-conventions`)
publish under a different, independent version on PyPI (`0.65b0`).

The instrumentation packages live in the *sibling* `opentelemetry-python-contrib`
repo, which is versioned independently (`0.XXb0`) and does **not** share
tags with the main repo — you can't reuse the main repo's `PV`. To find
which contrib tag pairs with a given main-repo release, check the main
repo's GitHub release title (e.g. release `v1.43.0`'s name is literally
"Version 1.43.0/0.64b0") — that trailing `0.64b0` is the paired contrib
tag. Gentoo-encode the beta suffix as `_beta` (`0.64b0` → `0.64_beta0`;
`MY_PV="${PV/_beta/b}"` reconstructs the upstream tag for `SRC_URI`).

Sanity-check the pairing against the release *dates* (main and contrib
releases for a matched pair land within the same day or so) before
trusting it — don't assume adjacency in the tag list is correspondence.

### Broadcom CDS discovery chain

The Broadcom Content Delivery Service (CDS) is what VMware Workstation
itself queries for updates. Walk it in three steps to find the current
version of any desktop hypervisor product:

1. **Vendor index** — lists all desktop hypervisor products and the
   per-product feed paths.

   ```
   curl https://softwareupdate.broadcom.com/cds/index.xml
   ```

   Each `<vendor>` entry has an `<indexfile>` (e.g. `ws-linux.xml`,
   `ws-windows.xml`, `fusion.xml`, `player-linux.xml`) and the same
   `<patchUrl>vmw-desktop</patchUrl>` for all of them. Combine to form
   the next URL.

2. **Product feed** — names the metadata schema version and the path to
   the actual bulletin.

   ```
   curl https://softwareupdate.broadcom.com/cds/vmw-desktop/ws-linux.xml
   ```

   Returns `<version>X.Y.Z</version>` (the *CDS schema* version, not the
   product version) and `<url>info-only/ws-linux/X.Y.Z/metadata.xml.gz</url>`.
   Concatenate `https://softwareupdate.broadcom.com/cds/vmw-desktop/`
   with that `<url>` to get the metadata URL.

3. **Bulletin metadata** — gzipped XML containing the human-readable
   release info.

   ```
   curl https://softwareupdate.broadcom.com/cds/vmw-desktop/info-only/ws-linux/8.0.0/metadata.xml.gz | gunzip
   ```

   The authoritative version is in the bulletin `<description>` text
   (e.g. "VMware Workstation Pro 25H2u1"). The structured `<version>`,
   `<buildNumber>`, and `<timeStamp>` fields are stale templates that
   Broadcom inherited from VMware's older CDS infrastructure and never
   refreshed — do not trust them.

### Lemonade bump procedure

`sci-ml/lemonade-server`'s root `CMakeLists.txt` tries system packages
first (`find_package`/`pkg_check_modules`) and falls back to
`FetchContent` (a live git clone — not viable in the portage sandbox)
for each one it doesn't find. Two of those probes don't recognize this
overlay's actual dependencies, and both fixes are line-anchored patches
that can silently stop applying on a bump:

- **`dev-cpp/cpp-httplib`** ships a CMake package config
  (`/usr/lib64/cmake/httplib/httplibConfig.cmake`) instead of a `.pc`
  file, so upstream's `pkg_search_module(HTTPLIB QUIET cpp-httplib
  httplib)` never finds it and falls through to `FetchContent`, which
  itself dies on a real upstream bug (an unquoted, empty
  `${CMAKE_SYSTEM_VERSION}` inside an `if()` — Gentoo's toolchain file
  sets `CMAKE_SYSTEM_NAME` explicitly, which puts CMake in
  pseudo-cross-compile mode and leaves `CMAKE_SYSTEM_VERSION` unset).
  Through 11.5.1, `files/lemonade-server-*-system-httplib-config.patch`
  added a `find_package(httplib CONFIG QUIET)` fallback, comparing
  `HTTPLIB_VERSION` manually against the floor instead of passing a
  version arg to `find_package()` — httplib's version file only
  accepts requests with a matching major **and minor** (pre-1.0 semver),
  which would reject a newer installed version against an older floor.
  **As of 11.5.2, upstream shipped the equivalent fix itself**: a new
  `cmake/DetectSystemHttplib.cmake` whose step 2 does exactly this
  (pre-checks `httplibConfigVersion.cmake`'s `PACKAGE_VERSION` by regex,
  then calls `find_package(httplib CONFIG QUIET)` with no version arg).
  The old patch's hunks no longer apply at all (not fuzzy — the
  `pkg_search_module(HTTPLIB ...)` call and surrounding code it targeted
  were deleted outright) — confirmed via a real build that dropping the
  patch still logs `Using system cpp-httplib (version X, >= floor)`.
  Don't assume this fix is permanent upstream behavior; re-check on every
  bump in case it regresses, but don't reflexively re-add the patch
  either — verify against the current source first.
- **`net-libs/mbedtls`** is SLOT `3` and names its pkg-config module,
  headers, and library `mbedcrypto-3`/`mbedtls3/mbedtls/md.h`/
  `libmbedcrypto-3.so`, not plain
  `mbedcrypto` — same failure mode, different subsystem (the
  digest-verification dependency probe, `pkg_check_modules(MBEDTLS QUIET
  mbedtls mbedx509 mbedcrypto)`). `files/lemonade-server-*-system-mbedcrypto-slot.patch`
  adds a fallback `pkg_check_modules` call using the `-3`-suffixed module
  names when the unsuffixed one fails. **This patch's exact shape is
  not stable across bumps** — 10.10.0→11.0.0 only needed a single
  `mbedcrypto` module (fixed via `pkg_search_module` alternate-name
  syntax), 11.0.0→11.5.0 rewrote upstream's probe to require
  `mbedtls`+`mbedx509`+`mbedcrypto` together (for new CLI HTTPS/TLS
  support), and 11.5.1→11.5.2 kept the probe's logic identical but moved
  the whole block from `src/cpp/cli/CMakeLists.txt` into the root
  `CMakeLists.txt` (part of centralizing the httplib/mbedtls wiring so
  both the CLI and server link one shared `lemonade-digest-crypto`
  target) — the patch needed re-targeting at the new file, not just a
  line offset. Always diff the *current* upstream file holding this
  probe (check both locations — it has moved before) against the patch
  before assuming it still applies, and confirm via a real build that
  the configure log says `Using system mbedtls for CLI HTTPS and digest
  verification`, not a `FetchContent` fallback message.

On every bump: diff the upstream `CMakeLists.txt`/`cli/CMakeLists.txt`
against the patched lines (context drift breaks the patch silently if
upstream refactors nearby code) and re-run a real `emerge` — a failed
`FetchContent` network fetch only surfaces when `FEATURES=network-sandbox`
actually works, which it does **not** in some sandboxed dev environments
(`Unable to unshare: EPERM`), so a build that "succeeds" there can still
fail on a real Gentoo host. Don't trust a clean build log without
checking for `Using system X` lines for every dependency.

`USE=webapp` runs `npm ci` against the npm registry inside
`BuildWebApp.cmake` — Gentoo has no vendoring eclass for npm, so this
is why `RESTRICT="network-sandbox"` is conditional on the flag. If a
future bump adds new npm dependencies, nothing here needs updating
(the lockfile-driven `npm ci` handles it), but if upstream ever adds a
way to vendor a `node_modules` tarball offline, revisit this — a fully
hermetic build would be preferable to opting out of network sandboxing.

The Tauri desktop app is packaged separately as `sci-ml/lemonade-desktop`
(`BUILD_TAURI_APP` stays `OFF` for `lemonade-server` — the desktop
package drives `npm`/`cargo` directly rather than going through CMake,
since the `tauri-app` CMake target's own `DEPENDS` only covers `src/app`'s
files, not `lemond`/`lemonade`, so there's nothing to gain from routing
through the shared build tree).

`sci-ml/lemonade-desktop`'s `CRATES` list (~590 entries) must be fully
regenerated from `src-tauri/Cargo.lock` on every bump — don't hand-edit
it. All 590 are plain crates.io registry entries (no git deps as of
11.0.0; if a future bump adds one, it needs `GIT_CRATES` instead).
**First diff `src-tauri/Cargo.lock` against the previous version's** —
it doesn't necessarily change even when `lemonade-server`'s `PV` does
(11.0.0→11.5.0 shipped a byte-identical `Cargo.lock`, `Cargo.toml`, and
`tauri.conf.json`, so `CRATES`/`LICENSE`/`RUST_MIN_VER` all carried over
unchanged and only the version string needed bumping; 11.5.2→11.6.0 was
the same story again). Don't regenerate reflexively — check first. To
regenerate when it *has* changed:

```
tar xzf <new-tarball> lemonade-<PV>/src/app/src-tauri/Cargo.lock
python3 -c '
import re
content = open("Cargo.lock").read()
crates = []
for b in content.split("[[package]]")[1:]:
    name = re.search(r"^name = \"([^\"]+)\"", b, re.M)
    ver = re.search(r"^version = \"([^\"]+)\"", b, re.M)
    src = re.search(r"^source = \"([^\"]+)\"", b, re.M)
    if src:  # skip the local lemonade-app package itself
        crates.append(f"{name.group(1)}@{ver.group(1)}")
print("\n".join(sorted(crates)))
'
```

Also re-verify on every bump:
- **`RUST_MIN_VER`** — don't just copy `src-tauri/Cargo.toml`'s
  `rust-version` (currently `1.77.2`); a vendored *dependency* crate can
  (and did, going from 10.10.0 to 11.0.0) declare a higher MSRV than
  Tauri's own floor. rust.eclass emits a QA notice naming the actual
  floor after a build — trust that over Tauri's Cargo.toml.
- **`LICENSE`** — re-scan every vendored crate's own `Cargo.toml` license
  field after fetching (a one-off `tar -xzOf <crate>.crate
  <crate>-<ver>/Cargo.toml | grep license` loop over `${CRATES}`), don't
  assume the existing license set still covers a changed dependency
  tree. New crates can introduce license atoms not yet in the `licenses/`
  directory used by either repo.
- The `pkgcheck` QA notice about ">300 CRATES, provide a crate tarball
  instead" is expected and intentionally not acted on — a single vendor
  tarball would mean self-hosting it somewhere, which defeats the point
  of using crates.io's own permanent per-version hosting instead.
