# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=hatchling

inherit distutils-r1 pypi

DESCRIPTION="Integration package connecting DeepSeek and LangChain"
HOMEPAGE="
	https://docs.langchain.com/oss/python/integrations/providers/deepseek
	https://pypi.org/project/langchain-deepseek/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RESTRICT="test"

RDEPEND="
	>=dev-python/langchain-core-1.4.0[${PYTHON_USEDEP}]
	<dev-python/langchain-core-2[${PYTHON_USEDEP}]
	>=dev-python/langchain-openai-1.1.0[${PYTHON_USEDEP}]
	<dev-python/langchain-openai-2[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"
