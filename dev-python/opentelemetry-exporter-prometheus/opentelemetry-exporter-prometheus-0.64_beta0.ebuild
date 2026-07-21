# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

# Unlike opentelemetry-api/sdk (whose own pyproject.toml version literally
# matches the monorepo git tag), this package's source lives in the same
# main opentelemetry-python repo but declares its OWN, independently
# numbered version (0.64b0) in its pyproject.toml at that same commit --
# same shape as opentelemetry-semantic-conventions. PV is that real,
# PyPI-published package version (what every consumer's RDEPEND atom
# actually references), Gentoo-encoded as 0.64_beta0; MY_TAG is the
# monorepo git tag that version was cut from, verified via the v1.43.0
# release notes' "Version 1.43.0/0.64b0" title -- the two numbers don't
# share an algorithmic mapping, so MY_TAG must be re-verified by hand on
# every bump rather than derived from PV.
MY_TAG="1.43.0"
MY_P="opentelemetry-python-${MY_TAG}"
DESCRIPTION="Prometheus Metric Exporter for OpenTelemetry"
HOMEPAGE="
	https://opentelemetry.io/
	https://pypi.org/project/opentelemetry-exporter-prometheus/
	https://github.com/open-telemetry/opentelemetry-python/
"
SRC_URI="
	https://github.com/open-telemetry/opentelemetry-python/archive/refs/tags/v${MY_TAG}.tar.gz
		-> ${MY_P}.gh.tar.gz
"
S="${WORKDIR}/${MY_P}/exporter/${PN}"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"

RDEPEND="
	>=dev-python/opentelemetry-api-1.12[${PYTHON_USEDEP}]
	<dev-python/opentelemetry-api-2[${PYTHON_USEDEP}]
	>=dev-python/opentelemetry-sdk-1.43.0[${PYTHON_USEDEP}]
	<dev-python/opentelemetry-sdk-1.44[${PYTHON_USEDEP}]
	>=dev-python/prometheus-client-0.5.0[${PYTHON_USEDEP}]
	<dev-python/prometheus-client-1.0.0[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"

# Not part of the released sdist/wheel; upstream's own test suite lives
# alongside the sibling packages in the monorepo checkout.
RESTRICT="test"
