# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=hatchling

inherit distutils-r1 pypi

DESCRIPTION="Integration package connecting Claude (Anthropic) APIs and LangChain"
HOMEPAGE="
	https://docs.langchain.com/oss/python/integrations/providers/anthropic
	https://pypi.org/project/langchain-anthropic/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RESTRICT="test"

RDEPEND="
	>=dev-python/anthropic-0.120.0[${PYTHON_USEDEP}]
	>=dev-python/langchain-core-1.5.2[${PYTHON_USEDEP}]
	>=dev-python/pydantic-2.7.4[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"
