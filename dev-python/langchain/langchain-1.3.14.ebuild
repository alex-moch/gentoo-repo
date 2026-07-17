# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=hatchling

inherit distutils-r1 pypi

DESCRIPTION="The agent engineering platform"
HOMEPAGE="
	https://github.com/langchain-ai/langchain
	https://pypi.org/project/langchain/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RESTRICT="test"

RDEPEND="
	>=dev-python/langchain-core-1.4.9[${PYTHON_USEDEP}]
	>=dev-python/langgraph-1.2.5[${PYTHON_USEDEP}]
	>=dev-python/pydantic-2.7.4[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"
