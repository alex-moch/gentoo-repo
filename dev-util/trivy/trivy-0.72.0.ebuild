# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module

DESCRIPTION="Vulnerability, misconfiguration and secret scanner for containers and IaC"
HOMEPAGE="https://trivy.dev/ https://github.com/aquasecurity/trivy"
SRC_URI="
	https://github.com/aquasecurity/trivy/archive/v${PV}.tar.gz -> ${P}.tar.gz
	https://gentoo.m68k.io/distfiles/${P}-deps.tar.xz
"

LICENSE="Apache-2.0 BSD BSD-2 ISC MIT MPL-2.0 Unlicense"
SLOT="0"
KEYWORDS="~amd64"

BDEPEND="${BDEPEND} >=dev-lang/go-1.26.3:="

src_compile() {
	# Trivy uses the encoding/json/v2 and encoding/json/jsontext stdlib
	# packages, which are still gated behind this experiment flag upstream.
	export GOEXPERIMENT=jsonv2

	ego build \
		-ldflags "-s -w -X github.com/aquasecurity/trivy/pkg/version/app.ver=${PV}" \
		-o ${PN} ./cmd/trivy
}

src_install() {
	dobin ${PN}
}
