# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module

DESCRIPTION="An advanced, yet simple, tunneling/pivoting tool using a TUN interface"
HOMEPAGE="https://github.com/nicocha30/ligolo-ng"
SRC_URI="
	https://github.com/nicocha30/ligolo-ng/archive/v${PV}.tar.gz -> ${P}.gh.tar.gz
	https://gentoo.m68k.io/distfiles/${P}-deps.tar.xz
"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"

BDEPEND=">=dev-lang/go-1.25.0"

src_compile() {
	# Upstream's own Makefile stamps -X main.build=..., but that variable
	# doesn't exist in cmd/{proxy,agent}/main.go (which declare version/
	# commit/date instead) -- likely drifted from a prior refactor, and a
	# silent no-op since `go build -X` doesn't error on an unmatched path.
	# Stamping the three real variables instead of reproducing that bug.
	local common_ldflags=(
		-s -w
		-X main.version=v${PV}
		-X main.commit=${PV}
		-X main.date=$(date -u +%Y-%m-%dT%H:%M:%SZ)
	)

	ego build -ldflags "${common_ldflags[*]}" -o ${PN}-proxy ./cmd/proxy
	ego build -ldflags "${common_ldflags[*]}" -o ${PN}-agent ./cmd/agent
}

src_install() {
	dobin ${PN}-proxy ${PN}-agent
	dodoc README.md
}

pkg_postinst() {
	elog "${PN}-proxy needs CAP_NET_ADMIN (or root) to create the TUN"
	elog "interface it tunnels traffic through."
}
