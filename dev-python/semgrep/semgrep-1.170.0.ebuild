# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Lightweight static analysis for many languages"
HOMEPAGE="
	https://semgrep.dev
	https://github.com/semgrep/semgrep
"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	>=dev-python/attrs-21.3[${PYTHON_USEDEP}]
	>=dev-python/boltons-21.0[${PYTHON_USEDEP}]
	>=dev-python/click-option-group-0.5[${PYTHON_USEDEP}]
	>=dev-python/click-8.1.8[${PYTHON_USEDEP}]
	>=dev-python/colorama-0.4.0[${PYTHON_USEDEP}]
	>=dev-python/exceptiongroup-1.2.0[${PYTHON_USEDEP}]
	>=dev-python/glom-23.3[${PYTHON_USEDEP}]
	>=dev-python/jsonschema-4.25.1[${PYTHON_USEDEP}]
	~dev-python/mcp-1.23.3[${PYTHON_USEDEP}]
	>=dev-python/opentelemetry-api-1.37.0[${PYTHON_USEDEP}]
	>=dev-python/opentelemetry-sdk-1.37.0[${PYTHON_USEDEP}]
	>=dev-python/opentelemetry-exporter-otlp-proto-http-1.37.0[${PYTHON_USEDEP}]
	~dev-python/opentelemetry-instrumentation-requests-0.64_beta0[${PYTHON_USEDEP}]
	~dev-python/opentelemetry-instrumentation-threading-0.64_beta0[${PYTHON_USEDEP}]
	>=dev-python/packaging-21.0[${PYTHON_USEDEP}]
	>=dev-python/peewee-3.14[${PYTHON_USEDEP}]
	>=dev-python/pyjwt-2.13.0[${PYTHON_USEDEP}]
	dev-python/cryptography[${PYTHON_USEDEP}]
	>=dev-python/requests-2.22[${PYTHON_USEDEP}]
	>=dev-python/rich-13.5.2[${PYTHON_USEDEP}]
	>=dev-python/ruamel-yaml-0.18.15[${PYTHON_USEDEP}]
	~dev-python/ruamel-yaml-clib-0.2.15[${PYTHON_USEDEP}]
	~dev-python/semantic-version-2.10.0[${PYTHON_USEDEP}]
	>=dev-python/tomli-2.4.0[${PYTHON_USEDEP}]
	>=dev-python/typing-extensions-4.2[${PYTHON_USEDEP}]
	>=dev-python/urllib3-2.0[${PYTHON_USEDEP}]
	>=dev-python/wcmatch-8.3[${PYTHON_USEDEP}]

	~dev-util/semgrep-core-bin-${PV}"
DEPEND="${RDEPEND}"
