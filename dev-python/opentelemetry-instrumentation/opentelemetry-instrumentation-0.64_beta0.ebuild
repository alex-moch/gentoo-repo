# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

MY_PV="${PV/_beta/b}"
MY_P="opentelemetry-python-contrib-${MY_PV}"
DESCRIPTION="Instrumentation Tools & Auto Instrumentation for OpenTelemetry Python"
HOMEPAGE="
	https://opentelemetry.io/
	https://pypi.org/project/opentelemetry-instrumentation/
	https://github.com/open-telemetry/opentelemetry-python-contrib/
"
SRC_URI="
	https://github.com/open-telemetry/opentelemetry-python-contrib/archive/refs/tags/v${MY_PV}.tar.gz
		-> ${MY_P}.gh.tar.gz
"
S="${WORKDIR}/${MY_P}/${PN}"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"

RDEPEND="
	>=dev-python/opentelemetry-api-1.4[${PYTHON_USEDEP}]
	<dev-python/opentelemetry-api-2[${PYTHON_USEDEP}]
	~dev-python/opentelemetry-semantic-conventions-1.43.0[${PYTHON_USEDEP}]
	>=dev-python/wrapt-1.0.0[${PYTHON_USEDEP}]
	<dev-python/wrapt-3.0.0[${PYTHON_USEDEP}]
	>=dev-python/packaging-18.0[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"

# Not part of the released sdist/wheel; upstream's own test suite lives
# alongside the sibling packages in the monorepo checkout.
RESTRICT="test"
