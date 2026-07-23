# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module

DESCRIPTION="In-depth attack surface mapping and asset discovery"
HOMEPAGE="https://github.com/owasp-amass/amass"
SRC_URI="
	https://github.com/owasp-amass/amass/archive/v${PV}.tar.gz -> ${P}.gh.tar.gz
	https://gentoo.m68k.io/distfiles/${P}-deps.tar.xz
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

BDEPEND=">=dev-lang/go-1.26.0"

src_compile() {
	CGO_ENABLED=0 ego build -o ${PN} ./cmd/${PN}
}

src_install() {
	dobin ${PN}
	dodoc README.md
	insinto /usr/share/${PN}
	doins resources/config.yaml resources/datasources.yaml
}

pkg_postinst() {
	elog "Only the core ${PN} CLI is packaged -- the Docker Compose-based"
	elog "asset-database / long-term-tracking deployment upstream also"
	elog "offers is out of scope here."
	elog ""
	elog "Documentation: https://owasp-amass.github.io/docs"
}
