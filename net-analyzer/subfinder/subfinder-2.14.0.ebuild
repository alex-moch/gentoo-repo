# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module

DESCRIPTION="A subdomain discovery tool that discovers valid subdomains for websites"
HOMEPAGE="https://github.com/projectdiscovery/subfinder"
SRC_URI="
	https://github.com/projectdiscovery/subfinder/archive/v${PV}.tar.gz -> ${P}.gh.tar.gz
	https://gentoo.m68k.io/distfiles/${P}-deps.tar.xz
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

BDEPEND=">=dev-lang/go-1.24.0"

# Strips subfinder's built-in self-update-check/nag (it phones home to
# GitHub to compare against the latest release) -- Portage manages
# versions, not the tool's own updater.
PATCHES=( "${FILESDIR}"/options.patch )

src_compile() {
	ego build -o ${PN} ./cmd/${PN}
}

src_install() {
	dobin ${PN}
	dodoc README.md
}
