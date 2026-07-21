# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

MY_P="opentelemetry-python-${PV}"
DESCRIPTION="OpenTelemetry Collector Protobuf over gRPC Exporter"
HOMEPAGE="
	https://opentelemetry.io/
	https://pypi.org/project/opentelemetry-exporter-otlp-proto-grpc/
	https://github.com/open-telemetry/opentelemetry-python/
"
SRC_URI="
	https://github.com/open-telemetry/opentelemetry-python/archive/refs/tags/v${PV}.tar.gz
		-> ${MY_P}.gh.tar.gz
"
S="${WORKDIR}/${MY_P}/exporter/${PN}"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"

# Real requires_dist floors grpcio differently per Python version
# (>=1.63.2 on 3.12, >=1.66.2 on 3.13, >=1.75.1 on 3.14+); Portage has no
# clean way to express a per-python-target floor in one RDEPEND, so this
# just takes the strictest (3.14) floor for every PYTHON_COMPAT target --
# moot in practice since the tree's dev-python/grpcio is already 1.82.1.
RDEPEND="
	>=dev-python/googleapis-common-protos-1.57[${PYTHON_USEDEP}]
	<dev-python/googleapis-common-protos-2[${PYTHON_USEDEP}]
	>=dev-python/grpcio-1.75.1[${PYTHON_USEDEP}]
	>=dev-python/opentelemetry-api-1.15[${PYTHON_USEDEP}]
	<dev-python/opentelemetry-api-2[${PYTHON_USEDEP}]
	~dev-python/opentelemetry-proto-${PV}[${PYTHON_USEDEP}]
	>=dev-python/opentelemetry-sdk-1.43.0[${PYTHON_USEDEP}]
	<dev-python/opentelemetry-sdk-1.44[${PYTHON_USEDEP}]
	~dev-python/opentelemetry-exporter-otlp-proto-common-${PV}[${PYTHON_USEDEP}]
	>=dev-python/typing-extensions-4.6.0[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"

# Not part of the released sdist/wheel; upstream's own test suite lives
# alongside the sibling packages in the monorepo checkout.
RESTRICT="test"
