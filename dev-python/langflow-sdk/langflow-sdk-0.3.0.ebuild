# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
# Upstream has never published an sdist for this package (every release,
# including pre-releases, is wheel-only on PyPI) -- install the real
# py3-none-any wheel directly, same mechanism as dev-python/chromadb.
DISTUTILS_USE_PEP517=no

inherit distutils-r1 pypi

DESCRIPTION="Python SDK for the Langflow REST API"
HOMEPAGE="
	https://github.com/langflow-ai/langflow
	https://pypi.org/project/langflow-sdk/
"

WHEEL_FILENAME="$(pypi_wheel_name "${PN/-/_}" "${PV}")"

SRC_URI="$(pypi_wheel_url "${PN/-/_}" "${PV}")"
S="${WORKDIR}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

# httpx's [http2] extra has no corresponding USE flag on this tree's
# dev-python/httpx -- translated to a hard dep on dev-python/h2, same as
# the equivalent qdrant-client/lfx situation elsewhere in this overlay.
RDEPEND="
	>=dev-python/httpx-0.24.0[${PYTHON_USEDEP}]
	<dev-python/httpx-1[${PYTHON_USEDEP}]
	dev-python/h2[${PYTHON_USEDEP}]
	>=dev-python/pydantic-2.0.0[${PYTHON_USEDEP}]
	<dev-python/pydantic-3[${PYTHON_USEDEP}]
	>=dev-python/pydantic-settings-2.10.1[${PYTHON_USEDEP}]
	<dev-python/pydantic-settings-3[${PYTHON_USEDEP}]
	>=dev-python/tomli-2.2.1[${PYTHON_USEDEP}]
	<dev-python/tomli-3[${PYTHON_USEDEP}]
	>=dev-python/typing-extensions-4.14.0[${PYTHON_USEDEP}]
	<dev-python/typing-extensions-5[${PYTHON_USEDEP}]
"

RESTRICT="test"

src_unpack() {
	:
}

python_compile() {
	distutils_wheel_install "${BUILD_DIR}/install" "${DISTDIR}/${WHEEL_FILENAME}"
}
