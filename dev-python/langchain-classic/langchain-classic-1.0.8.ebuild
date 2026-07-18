# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=hatchling

inherit distutils-r1 pypi

DESCRIPTION="Building applications with LLMs through composability"
HOMEPAGE="
	https://github.com/langchain-ai/langchain
	https://pypi.org/project/langchain-classic/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RESTRICT="test"

RDEPEND="
	>=dev-python/langchain-core-1.4.4[${PYTHON_USEDEP}]
	<dev-python/langchain-core-2[${PYTHON_USEDEP}]
	>=dev-python/langchain-text-splitters-1.1.2[${PYTHON_USEDEP}]
	<dev-python/langchain-text-splitters-2[${PYTHON_USEDEP}]
	>=dev-python/langsmith-0.1.17[${PYTHON_USEDEP}]
	<dev-python/langsmith-1[${PYTHON_USEDEP}]
	>=dev-python/pydantic-2.7.4[${PYTHON_USEDEP}]
	<dev-python/pydantic-3[${PYTHON_USEDEP}]
	>=dev-python/pyyaml-5.3.0[${PYTHON_USEDEP}]
	<dev-python/pyyaml-7[${PYTHON_USEDEP}]
	>=dev-python/requests-2.0.0[${PYTHON_USEDEP}]
	<dev-python/requests-3[${PYTHON_USEDEP}]
	>=dev-python/sqlalchemy-1.4.0[${PYTHON_USEDEP}]
	<dev-python/sqlalchemy-3[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"
