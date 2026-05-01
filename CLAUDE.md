# Conventions

## Commit messages

- Sentence case, not title case.
- Subject line ends with a full stop.
- Backticks around file and directory names.
- Body with a brief description before trailers.
- Always include `Signed-off-by: Alexander Moch <mail@alexmoch.com>`
- Include `Co-authored-by` only for significant contributions by Claude beyond typing assistance.

## Ebuilds

- Follow the [Gentoo Development Guide](https://devmanual.gentoo.org/) when in doubt on style.
- For new packages, check the main Gentoo tree and public overlays first; use existing ebuilds as boilerplate where useful.
- When working on a package, check whether a newer upstream release is available.
- Add `metadata.xml` if non-existent.

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
| `dev-debug/pwndbg` | Gentoo (official) | Version-pinned fork |
| `dev-vcs/gitleaks` | Pentoo | Forked, maintainer reassigned |
| `net-firewall/littlesnitch` | local | Written from scratch — no upstream ebuild reference; product page at https://obdev.at/products/littlesnitch-linux/index.html |
| `sci-ml/ollama` | GURU | Forked, maintainer reassigned, refactored |

## Upstream version checks

Endpoints to query for the latest upstream version. Fetch these directly
with `curl` rather than scraping vendor product pages. For GitHub-hosted
projects the JSON response's `tag_name` field is the latest stable
release (excluding pre-releases).

| Package | URL | Notes |
|---|---|---|
| `app-emulation/vmware-modules` | `https://api.github.com/repos/alex-moch/vmware-modules/commits` | Tracks `master`; ebuild's `COMMIT=` should match the first `sha` in the JSON response |
| `app-emulation/vmware-workstation` | `https://softwareupdate.broadcom.com/cds/vmw-desktop/info-only/ws-linux/8.0.0/metadata.xml.gz` | See discovery chain below |
| `dev-debug/pwndbg` | `https://api.github.com/repos/pwndbg/pwndbg/releases/latest` | Tag format `YYYY.MM.DD`; ebuild version drops the dots |
| `dev-vcs/gitleaks` | `https://api.github.com/repos/gitleaks/gitleaks/releases/latest` | Tag prefixed with `v` |
| `net-firewall/littlesnitch` | `https://obdev.at/products/littlesnitch-linux/download.html` | Parse the download URLs in the page (e.g. `littlesnitch-1.0.5-1-x86_64.pkg.tar.zst`); no machine-readable feed |
| `sci-ml/ollama` | `https://api.github.com/repos/ollama/ollama/releases/latest` | Tag prefixed with `v`; check `https://api.github.com/repos/ollama/ollama/releases` (without `/latest`) to also see pre-releases |

`acct-group/*` and `acct-user/*` packages have no upstream — they are
local system-account definitions and are version-bumped only when the
account schema needs to change.

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
