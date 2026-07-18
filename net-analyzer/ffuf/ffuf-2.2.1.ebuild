# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module

DESCRIPTION="A fast web fuzzer written in Go"
HOMEPAGE="https://github.com/ffuf/ffuf"
SRC_URI="
	https://github.com/ffuf/ffuf/archive/v${PV}.tar.gz -> ${P}.tar.gz
	https://gentoo.m68k.io/distfiles/${P}-deps.tar.xz
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

src_compile() {
	# Match upstream's goreleaser ldflags so the binary reports a plain
	# version instead of falling back to a stale "2.1.0-dev" default
	# (see pkg/ffuf/constants.go and the Version() logic in pkg/ffuf/util.go).
	local ldflags="-s -w"
	ldflags+=" -X github.com/ffuf/ffuf/v2/pkg/ffuf.VERSION=${PV}"
	ldflags+=" -X github.com/ffuf/ffuf/v2/pkg/ffuf.VERSION_APPENDIX="
	ego build -ldflags "${ldflags}" -o ${PN} .
}

src_install() {
	dobin ${PN}
}
