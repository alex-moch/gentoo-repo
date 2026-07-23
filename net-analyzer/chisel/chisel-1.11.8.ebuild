# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module

DESCRIPTION="A fast TCP/UDP tunnel over HTTP"
HOMEPAGE="https://github.com/jpillora/chisel"
SRC_URI="
	https://github.com/jpillora/chisel/archive/v${PV}.tar.gz -> ${P}.gh.tar.gz
	https://gentoo.m68k.io/distfiles/${P}-deps.tar.xz
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

BDEPEND=">=dev-lang/go-1.25.0"

src_compile() {
	# Matches upstream's own Makefile: the Linux build target uses
	# CGO_ENABLED=1 (unlike darwin/freebsd, which use 0).
	CGO_ENABLED=1 ego build \
		-ldflags "-s -w -X github.com/jpillora/chisel/share.BuildVersion=${PV}" \
		-o ${PN} .
}

src_install() {
	dobin ${PN}
	dodoc README.md
}
