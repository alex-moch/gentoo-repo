# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=pdm-backend

inherit distutils-r1 pypi

DESCRIPTION="Building applications with LLMs through composability"
HOMEPAGE="
	https://github.com/langchain-ai/langchain-experimental
	https://pypi.org/project/langchain-experimental/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RESTRICT="test"

RDEPEND="
	>=dev-python/langchain-community-0.4.2[${PYTHON_USEDEP}]
	<dev-python/langchain-community-1[${PYTHON_USEDEP}]
	>=dev-python/langchain-core-1.4.0[${PYTHON_USEDEP}]
	<dev-python/langchain-core-2[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"
