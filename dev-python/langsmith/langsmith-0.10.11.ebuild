# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=hatchling

inherit distutils-r1 pypi

DESCRIPTION="Client library for LangSmith, LangChain's observability platform"
HOMEPAGE="
	https://github.com/langchain-ai/langsmith-sdk
	https://pypi.org/project/langsmith/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RESTRICT="test"

RDEPEND="
	>=dev-python/anyio-3.5.0[${PYTHON_USEDEP}]
	>=dev-python/distro-1.7.0[${PYTHON_USEDEP}]
	>=dev-python/httpx-0.23.0[${PYTHON_USEDEP}]
	>=dev-python/orjson-3.9.14[${PYTHON_USEDEP}]
	>=dev-python/packaging-23.2[${PYTHON_USEDEP}]
	>=dev-python/pydantic-2[${PYTHON_USEDEP}]
	>=dev-python/requests-toolbelt-1.0.0[${PYTHON_USEDEP}]
	>=dev-python/requests-2.0.0[${PYTHON_USEDEP}]
	>=dev-python/sniffio-1.1[${PYTHON_USEDEP}]
	>=dev-python/typing-extensions-4.0.0[${PYTHON_USEDEP}]
	>=dev-python/uuid-utils-0.12.0[${PYTHON_USEDEP}]
	>=dev-python/websockets-15.0[${PYTHON_USEDEP}]
	>=dev-python/xxhash-3.0.0[${PYTHON_USEDEP}]
	>=dev-python/zstandard-0.23.0[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"
