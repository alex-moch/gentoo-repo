# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=hatchling

inherit distutils-r1 pypi

DESCRIPTION="Base abstractions that power the LangChain ecosystem"
HOMEPAGE="
	https://github.com/langchain-ai/langchain
	https://pypi.org/project/langchain-core/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RESTRICT="test"

RDEPEND="
	>=dev-python/jsonpatch-1.33[${PYTHON_USEDEP}]
	>=dev-python/langchain-protocol-0.0.17[${PYTHON_USEDEP}]
	>=dev-python/langsmith-0.3.45[${PYTHON_USEDEP}]
	>=dev-python/packaging-23.2.0[${PYTHON_USEDEP}]
	>=dev-python/pydantic-2.7.4[${PYTHON_USEDEP}]
	>=dev-python/pyyaml-5.3.0[${PYTHON_USEDEP}]
	>=dev-python/tenacity-8.1.0[${PYTHON_USEDEP}]
	>=dev-python/typing-extensions-4.7.0[${PYTHON_USEDEP}]
	>=dev-python/uuid-utils-0.12.0[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"
