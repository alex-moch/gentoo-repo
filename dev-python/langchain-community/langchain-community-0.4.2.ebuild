# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=hatchling

inherit distutils-r1 pypi

DESCRIPTION="Community contributed LangChain integrations"
HOMEPAGE="
	https://github.com/langchain-ai/langchain-community
	https://pypi.org/project/langchain-community/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RESTRICT="test"

RDEPEND="
	>=dev-python/aiohttp-3.8.3[${PYTHON_USEDEP}]
	<dev-python/aiohttp-4[${PYTHON_USEDEP}]
	>=dev-python/httpx-sse-0.4.0[${PYTHON_USEDEP}]
	<dev-python/httpx-sse-1[${PYTHON_USEDEP}]
	>=dev-python/langchain-classic-1.0.7[${PYTHON_USEDEP}]
	<dev-python/langchain-classic-2[${PYTHON_USEDEP}]
	>=dev-python/langchain-core-1.4.0[${PYTHON_USEDEP}]
	<dev-python/langchain-core-2[${PYTHON_USEDEP}]
	>=dev-python/langsmith-0.1.125[${PYTHON_USEDEP}]
	<dev-python/langsmith-1[${PYTHON_USEDEP}]
	>=dev-python/numpy-2.1.0[${PYTHON_USEDEP}]
	>=dev-python/pydantic-settings-2.10.1[${PYTHON_USEDEP}]
	<dev-python/pydantic-settings-3[${PYTHON_USEDEP}]
	>=dev-python/pyyaml-5.3.0[${PYTHON_USEDEP}]
	<dev-python/pyyaml-7[${PYTHON_USEDEP}]
	>=dev-python/requests-2.32.5[${PYTHON_USEDEP}]
	<dev-python/requests-3[${PYTHON_USEDEP}]
	>=dev-python/sqlalchemy-1.4.0[${PYTHON_USEDEP}]
	<dev-python/sqlalchemy-3[${PYTHON_USEDEP}]
	>=dev-python/tenacity-8.1.0[${PYTHON_USEDEP}]
	<dev-python/tenacity-10[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"
