# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=hatchling

inherit distutils-r1 pypi

DESCRIPTION="Integration package connecting Qdrant and LangChain"
HOMEPAGE="
	https://docs.langchain.com/oss/python/integrations/providers/qdrant
	https://pypi.org/project/langchain-qdrant/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RESTRICT="test"

RDEPEND="
	>=dev-python/langchain-core-1.0.0[${PYTHON_USEDEP}]
	<dev-python/langchain-core-2[${PYTHON_USEDEP}]
	>=dev-python/pydantic-2.7.4[${PYTHON_USEDEP}]
	<dev-python/pydantic-3[${PYTHON_USEDEP}]
	>=dev-python/qdrant-client-1.15.1[${PYTHON_USEDEP}]
	<dev-python/qdrant-client-2[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"
