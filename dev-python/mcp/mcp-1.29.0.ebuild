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

# pyjwt's real [crypto] extra isn't a USE flag on this tree's dev-python/pyjwt
# (Gentoo treats it as an optional runtime feature via optfeature, not IUSE) --
# translated to a hard dev-python/cryptography dep, same as before.
#
# pydantic/starlette floors are split upstream by python_version (>=2.11.0/
# >=0.27 below 3.14, >=2.12.0/>=0.48.0 at 3.14+) -- this tree only builds for
# python3_14, so only the higher floor applies.
RDEPEND="
	>=dev-python/anyio-4.5[${PYTHON_USEDEP}]
	>=dev-python/httpx-0.27.1[${PYTHON_USEDEP}]
	>=dev-python/httpx-sse-0.4[${PYTHON_USEDEP}]
	>=dev-python/jsonschema-4.20.0[${PYTHON_USEDEP}]
	>=dev-python/pydantic-2.12.0[${PYTHON_USEDEP}]
	>=dev-python/pydantic-settings-2.5.2[${PYTHON_USEDEP}]
	dev-python/cryptography[${PYTHON_USEDEP}]
	>=dev-python/pyjwt-2.10.1[${PYTHON_USEDEP}]
	>=dev-python/python-multipart-0.0.9[${PYTHON_USEDEP}]
	>=dev-python/starlette-0.48.0[${PYTHON_USEDEP}]
	>=dev-python/sse-starlette-1.6.1[${PYTHON_USEDEP}]
	>=dev-python/typing-extensions-4.9.0[${PYTHON_USEDEP}]
	>=dev-python/typing-inspection-0.4.1[${PYTHON_USEDEP}]
	>=dev-python/uvicorn-0.31.1[${PYTHON_USEDEP}]
	rich? ( >=dev-python/rich-13.9.4[${PYTHON_USEDEP}] )
	cli? (
		>=dev-python/typer-0.16.0[${PYTHON_USEDEP}]
		>=dev-python/python-dotenv-1.0.0[${PYTHON_USEDEP}]
	)
	ws? ( >=dev-python/websockets-15.0.1[${PYTHON_USEDEP}] )
"
DEPEND="${RDEPEND}"
