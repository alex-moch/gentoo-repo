# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=hatchling

inherit distutils-r1 pypi

DESCRIPTION="High-level APIs for creating and executing LangGraph agents and tools"
HOMEPAGE="
	https://github.com/langchain-ai/langgraph
	https://pypi.org/project/langgraph-prebuilt/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RESTRICT="test"

RDEPEND="
	>=dev-python/langchain-core-1.3.1[${PYTHON_USEDEP}]
	>=dev-python/langgraph-checkpoint-2.1.0[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"
