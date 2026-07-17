# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=hatchling

inherit distutils-r1 pypi

DESCRIPTION="Library with base interfaces for LangGraph checkpoint savers"
HOMEPAGE="
	https://github.com/langchain-ai/langgraph
	https://pypi.org/project/langgraph-checkpoint/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RESTRICT="test"

RDEPEND="
	>=dev-python/langchain-core-0.2.38[${PYTHON_USEDEP}]
	>=dev-python/ormsgpack-1.12.0[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"
