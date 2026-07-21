# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
# Upstream has never published an sdist for this package -- install the
# real py3-none-any wheel directly, same mechanism as dev-python/chromadb
# and dev-python/langflow-sdk.
DISTUTILS_USE_PEP517=no

inherit distutils-r1 pypi

DESCRIPTION="Langflow Executor -- a lightweight CLI to execute and serve Langflow AI flows"
HOMEPAGE="
	https://github.com/langflow-ai/langflow
	https://pypi.org/project/lfx/
"

WHEEL_FILENAME="$(pypi_wheel_name "${PN}" "${PV}")"

SRC_URI="$(pypi_wheel_url "${PN}" "${PV}")"
S="${WORKDIR}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

# httpx's [http2] extra has no corresponding USE flag on this tree's
# dev-python/httpx -- translated to a hard dep on dev-python/h2, same as
# dev-python/langflow-sdk and dev-python/qdrant-client elsewhere in this
# overlay.
#
# Five atoms below are loosened from lfx's real upstream pin because the
# tree has moved past what lfx was tested against, in either direction,
# and no other version exists to satisfy the real range -- same kind of
# unverified-but-reasonable deviation as the wcmatch floor relaxation
# documented in CLAUDE.md's semgrep bump procedure:
#   - aiofiles:  real pin is <25.0.0, tree only has 25.1.0+
#   - rich:      real pin is <14.0.0, tree only has 14.3.4+
#   - structlog: real pin is <26.0.0, tree only has 26.1.0+
#   - chardet:   real pin is >=7.3.0, tree only has 6.0.0_p1 (older, not newer)
#   - setuptools: real pin is [80.0.0,81.0.0), tree has 79.0.1/82.0.1/83.0.0
RDEPEND="
	>=dev-python/ag-ui-protocol-0.1.10[${PYTHON_USEDEP}]
	>=dev-python/aiofile-3.8.0[${PYTHON_USEDEP}]
	<dev-python/aiofile-4[${PYTHON_USEDEP}]
	dev-python/aiofiles[${PYTHON_USEDEP}]
	>=dev-python/asyncer-0.0.8[${PYTHON_USEDEP}]
	<dev-python/asyncer-1[${PYTHON_USEDEP}]
	>=dev-python/cachetools-6.0.0[${PYTHON_USEDEP}]
	>=dev-python/chardet-6.0.0_p1[${PYTHON_USEDEP}]
	>=dev-python/cryptography-48.0.1[${PYTHON_USEDEP}]
	>=dev-python/defusedxml-0.7.1[${PYTHON_USEDEP}]
	<dev-python/defusedxml-1[${PYTHON_USEDEP}]
	>=dev-python/docstring-parser-0.16[${PYTHON_USEDEP}]
	<dev-python/docstring-parser-1[${PYTHON_USEDEP}]
	>=dev-python/emoji-2.14.1[${PYTHON_USEDEP}]
	<dev-python/emoji-3[${PYTHON_USEDEP}]
	>=dev-python/fastapi-0.135.0[${PYTHON_USEDEP}]
	<dev-python/fastapi-1[${PYTHON_USEDEP}]
	>=dev-python/filelock-3.20.1[${PYTHON_USEDEP}]
	<dev-python/filelock-4[${PYTHON_USEDEP}]
	>=dev-python/httpx-0.24.0[${PYTHON_USEDEP}]
	<dev-python/httpx-1[${PYTHON_USEDEP}]
	dev-python/h2[${PYTHON_USEDEP}]
	>=dev-python/json-repair-0.30.3[${PYTHON_USEDEP}]
	<dev-python/json-repair-1[${PYTHON_USEDEP}]
	>=dev-python/langchain-1.3.0[${PYTHON_USEDEP}]
	<dev-python/langchain-1.4[${PYTHON_USEDEP}]
	>=dev-python/langchain-classic-1.0.7[${PYTHON_USEDEP}]
	<dev-python/langchain-classic-1.1[${PYTHON_USEDEP}]
	>=dev-python/langchain-core-1.2.28[${PYTHON_USEDEP}]
	<dev-python/langchain-core-2[${PYTHON_USEDEP}]
	>=dev-python/langflow-sdk-0.2.1[${PYTHON_USEDEP}]
	>=dev-python/loguru-0.7.3[${PYTHON_USEDEP}]
	<dev-python/loguru-1[${PYTHON_USEDEP}]
	>=dev-python/markitdown-0.1.4[${PYTHON_USEDEP}]
	<dev-python/markitdown-2[${PYTHON_USEDEP}]
	>=dev-python/mcp-1.17.0[${PYTHON_USEDEP}]
	<dev-python/mcp-2[${PYTHON_USEDEP}]
	>=dev-python/nanoid-2.0.0[${PYTHON_USEDEP}]
	<dev-python/nanoid-3[${PYTHON_USEDEP}]
	>=dev-python/networkx-3.4.2[${PYTHON_USEDEP}]
	<dev-python/networkx-4[${PYTHON_USEDEP}]
	>=dev-python/orjson-3.11.6[${PYTHON_USEDEP}]
	<dev-python/orjson-4[${PYTHON_USEDEP}]
	>=dev-python/pandas-2.0.0[${PYTHON_USEDEP}]
	<dev-python/pandas-3[${PYTHON_USEDEP}]
	>=dev-python/libpass-1.7.4[${PYTHON_USEDEP}]
	<dev-python/libpass-2[${PYTHON_USEDEP}]
	>=dev-python/pillow-11.1.0[${PYTHON_USEDEP}]
	<dev-python/pillow-13[${PYTHON_USEDEP}]
	>=dev-python/platformdirs-4.3.8[${PYTHON_USEDEP}]
	<dev-python/platformdirs-5[${PYTHON_USEDEP}]
	>=dev-python/pydantic-2.0.0[${PYTHON_USEDEP}]
	<dev-python/pydantic-3[${PYTHON_USEDEP}]
	>=dev-python/pydantic-settings-2.10.1[${PYTHON_USEDEP}]
	<dev-python/pydantic-settings-3[${PYTHON_USEDEP}]
	>=dev-python/pypdf-6.10.0[${PYTHON_USEDEP}]
	<dev-python/pypdf-7[${PYTHON_USEDEP}]
	>=dev-python/python-dotenv-1.0.0[${PYTHON_USEDEP}]
	<dev-python/python-dotenv-2[${PYTHON_USEDEP}]
	>=dev-python/pyyaml-6.0.0[${PYTHON_USEDEP}]
	<dev-python/pyyaml-7[${PYTHON_USEDEP}]
	>=dev-python/rich-13.0.0[${PYTHON_USEDEP}]
	>=dev-python/setuptools-80.0.0[${PYTHON_USEDEP}]
	>=dev-python/structlog-25.4.0[${PYTHON_USEDEP}]
	>=dev-python/tomli-2.2.1[${PYTHON_USEDEP}]
	<dev-python/tomli-3[${PYTHON_USEDEP}]
	>=dev-python/typer-0.16.0[${PYTHON_USEDEP}]
	<dev-python/typer-1[${PYTHON_USEDEP}]
	>=dev-python/typing-extensions-4.14.0[${PYTHON_USEDEP}]
	<dev-python/typing-extensions-5[${PYTHON_USEDEP}]
	>=dev-python/uvicorn-0.34.3[${PYTHON_USEDEP}]
	<dev-python/uvicorn-1[${PYTHON_USEDEP}]
	>=dev-python/validators-0.34.0[${PYTHON_USEDEP}]
	<dev-python/validators-1[${PYTHON_USEDEP}]
	>=dev-python/wheel-0.46.2[${PYTHON_USEDEP}]
	<dev-python/wheel-1[${PYTHON_USEDEP}]
"

RESTRICT="test"

src_unpack() {
	:
}

python_compile() {
	distutils_wheel_install "${BUILD_DIR}/install" "${DISTDIR}/${WHEEL_FILENAME}"
}
