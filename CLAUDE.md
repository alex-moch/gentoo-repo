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
| `app-emulation/vmware-modules` | local | Tracks https://github.com/alex-moch/vmware-modules |
| `app-emulation/vmware-workstation` | hybrid: nest + pg_overlay + pf4public | Heavy local rework |
| `dev-debug/pwndbg` | Gentoo (official) | Version-pinned fork, now **ahead** of the official tree and carrying local patches (capstone de-vendor via `src_prepare`, `niche-elf` dep, `pycparser` floor). No longer byte-identical to upstream — do not assume a clean diff/rebase |
| `dev-python/niche-elf` | local | Created here from pwndbg's PyPI dependency (upstream `github.com/pwndbg/niche-elf`); pure-Python |
| `dev-util/Tensile` | Gentoo (official) | Temporary local hold — do not update; remove once the official tree carries a sufficient version |
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
| `dev-debug/pwndbg` | `https://api.github.com/repos/pwndbg/pwndbg/releases/latest` | Tag format `YYYY.MM.DD`; ebuild version drops the dots. See bump procedure below |
| `dev-python/niche-elf` | (follows pwndbg) | Version is dictated by pwndbg's `pyproject.toml` pin, not bumped independently |
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
