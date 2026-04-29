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
