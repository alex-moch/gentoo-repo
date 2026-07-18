# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module

DESCRIPTION="A tool to brute-force URIs and DNS subdomains"
HOMEPAGE="https://github.com/OJ/gobuster"
SRC_URI="
	https://github.com/OJ/gobuster/archive/v${PV}.tar.gz -> ${P}.tar.gz
	https://gentoo.m68k.io/distfiles/${P}-deps.tar.xz
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

# go.mod requires go 1.25; raise the eclass's >=1.24.11 floor.
BDEPEND="
	>=dev-lang/go-1.25:=
	app-arch/unzip
"

src_compile() {
	ego build -o ${PN} .
}

src_install() {
	dobin ${PN}
}
