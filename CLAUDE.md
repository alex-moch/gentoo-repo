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
| `acct-group/ollama` | GURU | Forked, maintainer reassigned |
| `acct-group/vmware` | local | Created here |
| `acct-user/ollama` | GURU | Forked, maintainer reassigned |
| `app-forensics/sleuthkit` | Gentoo (official) | Forked, maintainer reassigned. Carries local patches: refreshed `exclude-usr-local`, plus `gnuconfig_update` on the bundled libewf so `USE=ewf` builds on `aarch64`/`musl` |
| `app-emulation/vmware-modules` | local | Tracks https://github.com/alex-moch/vmware-modules |
| `app-emulation/vmware-workstation` | hybrid: nest + pg_overlay + pf4public | Heavy local rework |
| `app-misc/claude-desktop` | local | Written from scratch — no upstream ebuild reference. Repackages Anthropic's official `.deb` (a prebuilt Electron bundle) into `/opt`. `RDEPEND` derived from the shipped binaries' ELF `NEEDED` set; the Debian maintainer scripts (AppArmor userns profile, apt-repo registration) are intentionally dropped as Debian-specific. Docs at https://code.claude.com/docs/en/desktop-linux |
| `dev-debug/pwndbg` | Gentoo (official) | Version-pinned fork, now **ahead** of the official tree and carrying local patches (capstone de-vendor via `src_prepare`, `niche-elf` dep, `pycparser` floor). No longer byte-identical to upstream — do not assume a clean diff/rebase |
| `dev-python/niche-elf` | local | Created here from pwndbg's PyPI dependency (upstream `github.com/pwndbg/niche-elf`); pure-Python |
| `dev-python/face` | Pentoo | Forked, maintainer reassigned. Pulled in as a `dev-python/glom` sub-dependency |
| `dev-python/glom` | Pentoo | Forked, maintainer reassigned. Pentoo's copy was the only source for a `dev-python/semgrep` dependency |
| `dev-python/httpx-sse` | Pentoo | Forked, maintainer reassigned. Pulled in as a `dev-python/mcp` sub-dependency |
| `dev-python/mcp` | Pentoo | Forked, maintainer reassigned, version-bumped (1.14.0 → 1.23.3) to satisfy `dev-python/semgrep`'s exact `mcp==` pin |
| `dev-python/opentelemetry-{proto,exporter-otlp-proto-common,exporter-otlp-proto-http,instrumentation,instrumentation-requests,instrumentation-threading,util-http}` | local | Created here — not yet packaged in Gentoo or GURU. `proto`/`exporter-otlp-proto-{common,http}` track the same `opentelemetry-python` monorepo tag as the tree's existing `opentelemetry-api`/`sdk`/`semantic-conventions` (currently `1.43.0`); `instrumentation`/`instrumentation-{requests,threading}`/`util-http` track the sibling `opentelemetry-python-contrib` repo (currently `0.64b0`, Gentoo-versioned `0.64_beta0`). See "OpenTelemetry paired-tag resolution" below before bumping any of these |
| `dev-python/semgrep` | Pentoo | Forked, maintainer reassigned, heavily version-bumped (1.75.0 → 1.170.0, ~2 years/95 releases). See "semgrep bump procedure" below |
| `dev-python/sse-starlette` | Pentoo | Forked, maintainer reassigned. Pulled in as a `dev-python/mcp` sub-dependency |
| `dev-util/Tensile` | Gentoo (official) | Temporary local hold — do not update; remove once the official tree carries a sufficient version |
| `dev-util/semgrep-core-bin` | Pentoo | Forked, maintainer reassigned, heavily reworked. Upstream's wheel now bundles `semgrep-core`'s native shared-lib dependencies (`bin/libs/`) instead of linking the host's — install layout changed from a flat `dobin` to a private `/usr/libexec/semgrep-core-bin/` dir + symlink. See "semgrep bump procedure" below |
| `dev-vcs/gitleaks` | Pentoo | Forked, maintainer reassigned |
| `net-firewall/littlesnitch` | local | Written from scratch — no upstream ebuild reference; product page at https://obdev.at/products/littlesnitch-linux/index.html |
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

| Package | URL | Notes |
|---|---|---|
| `app-emulation/vmware-modules` | `https://api.github.com/repos/alex-moch/vmware-modules/commits` | Tracks `master`; ebuild's `COMMIT=` should match the first `sha` in the JSON response |
| `app-emulation/vmware-workstation` | `https://softwareupdate.broadcom.com/cds/vmw-desktop/info-only/ws-linux/8.0.0/metadata.xml.gz` | See discovery chain below |
| `app-forensics/sleuthkit` | `https://api.github.com/repos/sleuthkit/sleuthkit/releases/latest` | Tag format `sleuthkit-X.Y.Z`; ebuild version is the `X.Y.Z` part. On bump, re-check `tsk/Makefile.am`'s `-version-info` first field for the `SLOT` subslot |
| `app-misc/claude-desktop` | `https://downloads.claude.ai/claude-desktop/apt/stable/dists/stable/main/binary-amd64/Packages` | No releases feed — parse the apt `Packages` index. Latest: `curl -fsSL <url> \| awk '/^Version:/{print $2}' \| sort -V \| tail -1`. Distfile is `claude-desktop_${PV}_${arch}.deb` under `.../pool/main/c/claude-desktop/`; the `.deb`'s own `SHA256` is in the same `Packages` block. Since it's a binary repackage, on bump re-scan the bundle's ELF `NEEDED` sonames (`scanelf -qn`) for new library deps before trusting the old `RDEPEND` |
| `dev-debug/pwndbg` | `https://api.github.com/repos/pwndbg/pwndbg/releases/latest` | Tag format `YYYY.MM.DD`; ebuild version drops the dots. See bump procedure below |
| `dev-python/niche-elf` | (follows pwndbg) | Version is dictated by pwndbg's `pyproject.toml` pin, not bumped independently |
| `dev-python/mcp` | `https://pypi.org/pypi/mcp/json` | `info.version` is latest. Only needs bumping when `dev-python/semgrep`'s exact `mcp==` pin moves |
| `dev-python/opentelemetry-*` (see provenance table) | `https://api.github.com/repos/open-telemetry/opentelemetry-python/releases/latest` and `.../opentelemetry-python-contrib/releases/latest` | Only needs bumping when `dev-python/semgrep`'s `opentelemetry-*` floors move. See "OpenTelemetry paired-tag resolution" below |
| `dev-python/semgrep` | `https://api.github.com/repos/semgrep/semgrep/releases/latest` | Tag prefixed with `v`. See "semgrep bump procedure" below before touching this or `dev-util/semgrep-core-bin` |
| `dev-util/semgrep-core-bin` | (follows `dev-python/semgrep`) | Always bump in lockstep with `dev-python/semgrep` — same `PV` |
| `dev-vcs/gitleaks` | `https://api.github.com/repos/gitleaks/gitleaks/releases/latest` | Tag prefixed with `v` |
| `net-firewall/littlesnitch` | `https://obdev.at/products/littlesnitch-linux/download.html` | Parse the download URLs in the page (e.g. `littlesnitch-1.0.5-1-x86_64.pkg.tar.zst`); no machine-readable feed |
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
  imports to the system `dev-libs/capstone` (`s/capstone6pwndbg/capstone/`)
  and reconciles one renamed constant (`CS_MODE_RISCVC` →
  `CS_MODE_RISCV_C`). Re-verify both on each bump: the import name may
  change, and new capstone symbols may be missing from Gentoo's capstone.
- **`niche-elf`** — separate `dev-python/niche-elf` package; keep its
  version matching pwndbg's pin.
- **`pycparser`** and other floors — diff the `pyproject.toml`
  `dependencies` list against the ebuild's `RDEPEND` and update bounds.

On every bump: fetch the source at the pinned tag, `grep -r capstone6pwndbg`
and diff `pyproject.toml`, then runtime smoke-test (`emerge` + launch).

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
  in lockstep if it moved.
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
