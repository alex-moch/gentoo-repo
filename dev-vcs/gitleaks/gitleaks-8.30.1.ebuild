# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module

DESCRIPTION="Scan git repos (or files) for secrets using regex and entropy"
HOMEPAGE="https://github.com/gitleaks/gitleaks"
SRC_URI="
	https://github.com/gitleaks/gitleaks/archive/v${PV}.tar.gz -> ${P}.tar.gz
	https://gentoo.m68k.io/distfiles/${P}-deps.tar.xz
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"

RDEPEND="dev-vcs/git"

src_compile() {
	ego build \
		-ldflags "-s -w -X github.com/zricethezav/gitleaks/v8/cmd.Version=${PV}" \
		-o ${PN} .
}

src_install() {
	dobin ${PN}
}
