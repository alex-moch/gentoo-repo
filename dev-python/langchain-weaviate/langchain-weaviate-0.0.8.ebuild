# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=poetry-core

inherit distutils-r1 pypi

DESCRIPTION="Integration package connecting Weaviate and LangChain"
HOMEPAGE="
	https://github.com/langchain-ai/langchain-weaviate
	https://pypi.org/project/langchain-weaviate/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RESTRICT="test"

RDEPEND="
	>=dev-python/langchain-core-1.4.7[${PYTHON_USEDEP}]
	<dev-python/langchain-core-2[${PYTHON_USEDEP}]
	>=dev-python/numpy-1.26.2[${PYTHON_USEDEP}]
	<dev-python/numpy-3[${PYTHON_USEDEP}]
	>=dev-python/weaviate-client-4.0.0[${PYTHON_USEDEP}]
	<dev-python/weaviate-client-5[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"
