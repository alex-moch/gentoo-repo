# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=hatchling

inherit distutils-r1 pypi

DESCRIPTION="Client library for interacting with the LangGraph API"
HOMEPAGE="
	https://github.com/langchain-ai/langgraph
	https://pypi.org/project/langgraph-sdk/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RESTRICT="test"

RDEPEND="
	>=dev-python/httpx-0.25.2[${PYTHON_USEDEP}]
	>=dev-python/langchain-core-1.4.0[${PYTHON_USEDEP}]
	>=dev-python/langchain-protocol-0.0.15[${PYTHON_USEDEP}]
	>=dev-python/orjson-3.11.5[${PYTHON_USEDEP}]
	>=dev-python/websockets-14[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"
