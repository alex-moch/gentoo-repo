# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module

DESCRIPTION="Simple and configurable vulnerability scanner based on YAML templates"
HOMEPAGE="https://github.com/projectdiscovery/nuclei https://projectdiscovery.io"
SRC_URI="
	https://github.com/projectdiscovery/nuclei/archive/refs/tags/v${PV}.tar.gz -> ${P}.gh.tar.gz
	https://gentoo.m68k.io/distfiles/${P}-deps.tar.xz
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+templates"

RDEPEND="
	templates? ( net-analyzer/nuclei-templates )
"
DEPEND="${RDEPEND}"

src_compile() {
	local nuclei_ldflags=(
		-s -w
		-X main.Version=${PV}
		-X main.BuildTime=$(date -u +%Y-%m-%dT%H:%M:%SZ)
	)

	ego build \
		-buildmode=pie \
		-ldflags "${nuclei_ldflags[*]}" \
		-o ${PN} \
		./cmd/${PN}
}

src_install() {
	dobin ${PN}
	dodoc README.md CONTRIBUTING.md

	if [[ -f man/man1/nuclei.1 ]]; then
		doman man/man1/nuclei.1
	fi
}

pkg_postinst() {
	elog "More information:"
	elog "  - Documentation: https://docs.projectdiscovery.io/tools/nuclei/"
	elog "  - Templates: https://github.com/projectdiscovery/nuclei-templates"
	elog ""
}
