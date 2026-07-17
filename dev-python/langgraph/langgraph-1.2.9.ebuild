# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=hatchling

inherit distutils-r1 pypi

DESCRIPTION="Low-level orchestration framework for building stateful, long-running agents"
HOMEPAGE="
	https://github.com/langchain-ai/langgraph
	https://pypi.org/project/langgraph/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RESTRICT="test"

RDEPEND="
	>=dev-python/langchain-core-1.4.7[${PYTHON_USEDEP}]
	>=dev-python/langgraph-checkpoint-4.1.0[${PYTHON_USEDEP}]
	>=dev-python/langgraph-prebuilt-1.1.0[${PYTHON_USEDEP}]
	>=dev-python/langgraph-sdk-0.4.2[${PYTHON_USEDEP}]
	>=dev-python/pydantic-2.7.4[${PYTHON_USEDEP}]
	>=dev-python/xxhash-3.5.0[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"
