# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=hatchling

inherit distutils-r1 pypi

DESCRIPTION="Integration package connecting Perplexity and LangChain"
HOMEPAGE="
	https://docs.langchain.com/oss/python/integrations/providers/perplexity
	https://pypi.org/project/langchain-perplexity/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RESTRICT="test"

RDEPEND="
	>=dev-python/langchain-core-1.4.0[${PYTHON_USEDEP}]
	>=dev-python/perplexityai-0.34.1[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"
