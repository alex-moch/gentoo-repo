# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=hatchling

inherit distutils-r1 pypi

DESCRIPTION="Integration package connecting Ollama and LangChain"
HOMEPAGE="
	https://docs.langchain.com/oss/python/integrations/providers/ollama
	https://pypi.org/project/langchain-ollama/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RESTRICT="test"

RDEPEND="
	>=dev-python/langchain-core-1.2.21[${PYTHON_USEDEP}]
	>=dev-python/ollama-0.6.1[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"
