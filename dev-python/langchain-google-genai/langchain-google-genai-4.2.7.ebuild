# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=hatchling

inherit distutils-r1 pypi

DESCRIPTION="Integration package connecting Google's genai package and LangChain"
HOMEPAGE="
	https://docs.langchain.com/oss/python/integrations/providers/google
	https://pypi.org/project/langchain-google-genai/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RESTRICT="test"

RDEPEND="
	>=dev-python/filetype-1.2.0[${PYTHON_USEDEP}]
	>=dev-python/google-genai-1.65.0[${PYTHON_USEDEP}]
	>=dev-python/langchain-core-1.4.7[${PYTHON_USEDEP}]
	>=dev-python/pydantic-2.0.0[${PYTHON_USEDEP}]
	<dev-python/pydantic-3[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"
