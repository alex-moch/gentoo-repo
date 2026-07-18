# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

MY_PV="${PV/_beta/b}"
MY_P="opentelemetry-python-contrib-${MY_PV}"
DESCRIPTION="OpenTelemetry FastAPI instrumentation"
HOMEPAGE="
	https://opentelemetry.io/
	https://pypi.org/project/opentelemetry-instrumentation-fastapi/
	https://github.com/open-telemetry/opentelemetry-python-contrib/
"
SRC_URI="
	https://github.com/open-telemetry/opentelemetry-python-contrib/archive/refs/tags/v${MY_PV}.tar.gz
		-> ${MY_P}.gh.tar.gz
"
S="${WORKDIR}/${MY_P}/instrumentation/${PN}"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"

RDEPEND="
	>=dev-python/opentelemetry-api-1.12[${PYTHON_USEDEP}]
	~dev-python/opentelemetry-instrumentation-${PV}[${PYTHON_USEDEP}]
	~dev-python/opentelemetry-instrumentation-asgi-${PV}[${PYTHON_USEDEP}]
	~dev-python/opentelemetry-semantic-conventions-1.43.0[${PYTHON_USEDEP}]
	~dev-python/opentelemetry-util-http-${PV}[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"

# fastapi itself is upstream's "instruments" extra (the target library this
# instruments, not a hard runtime requirement of this package), and unlike
# the requests/urllib3 siblings it cannot be added unconditionally here:
# dev-python/fastapi in the gentoo tree only supports PYTHON_COMPAT
# python3_{14,15} (not 12/13), which makes a same-PYTHON_USEDEP RDEPEND
# unsolvable. The actual consumer (dev-python/langflow-base) already pulls
# in dev-python/fastapi directly, so it is intentionally omitted here.

# Not part of the released sdist/wheel; upstream's own test suite lives
# alongside the sibling packages in the monorepo checkout.
RESTRICT="test"
