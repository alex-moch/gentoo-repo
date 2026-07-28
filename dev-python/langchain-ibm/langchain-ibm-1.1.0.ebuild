# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=pdm-backend

inherit distutils-r1 pypi

DESCRIPTION="Integration package connecting IBM watsonx.ai and LangChain"
HOMEPAGE="
	https://github.com/langchain-ai/langchain-ibm
	https://pypi.org/project/langchain-ibm/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RESTRICT="test"

# Upstream splits the ibm-watsonx-ai floor by python_version (>=1.3.37 for
# <3.14, >=1.5.13 for ==3.14) -- this tree only builds for python3_14, so
# only the higher floor applies; dev-python/ibm-watsonx-ai-1.6.0 satisfies it.
RDEPEND="
	>=dev-python/langchain-core-1.2.22[${PYTHON_USEDEP}]
	<dev-python/langchain-core-2[${PYTHON_USEDEP}]
	>=dev-python/ibm-watsonx-ai-1.5.13[${PYTHON_USEDEP}]
	<dev-python/ibm-watsonx-ai-2[${PYTHON_USEDEP}]
	>=dev-python/json-repair-0.30.0[${PYTHON_USEDEP}]
	<dev-python/json-repair-1[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"
