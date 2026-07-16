# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=hatchling

inherit distutils-r1 pypi

DESCRIPTION="Python SDK for Model Context Protocol"
HOMEPAGE="https://github.com/modelcontextprotocol/python-sdk"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 ~arm64"
IUSE="cli rich ws"

RESTRICT="test"

RDEPEND="
	dev-python/anyio[${PYTHON_USEDEP}]
	>=dev-python/httpx-0.27.1[${PYTHON_USEDEP}]
	dev-python/httpx-sse[${PYTHON_USEDEP}]
	>=dev-python/jsonschema-4.20.0[${PYTHON_USEDEP}]
	>=dev-python/pydantic-2.11.0[${PYTHON_USEDEP}]
	dev-python/pydantic-settings[${PYTHON_USEDEP}]
	dev-python/cryptography[${PYTHON_USEDEP}]
	dev-python/pyjwt[${PYTHON_USEDEP}]
	dev-python/python-multipart[${PYTHON_USEDEP}]
	dev-python/starlette[${PYTHON_USEDEP}]
	dev-python/sse-starlette[${PYTHON_USEDEP}]
	dev-python/typing-extensions[${PYTHON_USEDEP}]
	dev-python/typing-inspection[${PYTHON_USEDEP}]
	dev-python/uvicorn[${PYTHON_USEDEP}]
	rich? ( dev-python/rich[${PYTHON_USEDEP}] )
	cli? (
		dev-python/typer[${PYTHON_USEDEP}]
		dev-python/python-dotenv[${PYTHON_USEDEP}]
	)
	ws? ( dev-python/websockets[${PYTHON_USEDEP}] )
"
DEPEND="${RDEPEND}"
