# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=hatchling

inherit distutils-r1 pypi

DESCRIPTION="Integration package connecting MongoDB and LangChain"
HOMEPAGE="
	https://github.com/langchain-ai/langchain-mongodb
	https://pypi.org/project/langchain-mongodb/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RESTRICT="test"

RDEPEND="
	>=dev-python/langchain-1.0[${PYTHON_USEDEP}]
	>=dev-python/langchain-classic-1.0[${PYTHON_USEDEP}]
	>=dev-python/langchain-core-1.2.5[${PYTHON_USEDEP}]
	>=dev-python/langchain-text-splitters-1.0[${PYTHON_USEDEP}]
	>=dev-python/lark-1.1.9[${PYTHON_USEDEP}]
	<dev-python/lark-2[${PYTHON_USEDEP}]
	>=dev-python/numpy-1.26[${PYTHON_USEDEP}]
	>=dev-python/pymongo-4.6.1[${PYTHON_USEDEP}]
	>=dev-python/pymongo-search-utils-0.2.1[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"
