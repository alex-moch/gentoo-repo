# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=setuptools

inherit distutils-r1 pypi

DESCRIPTION="AssemblyAI Python SDK"
HOMEPAGE="
	https://github.com/AssemblyAI/assemblyai-python-sdk
	https://pypi.org/project/assemblyai/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RESTRICT="test"

RDEPEND="
	>=dev-python/httpx-0.19.0[${PYTHON_USEDEP}]
	>=dev-python/typing-extensions-3.7[${PYTHON_USEDEP}]
	>=dev-python/websockets-11.0[${PYTHON_USEDEP}]
	$(python_gen_cond_dep '
		>=dev-python/pydantic-1.10.17[${PYTHON_USEDEP}]
	' python3_12 python3_13)
	$(python_gen_cond_dep '
		>=dev-python/pydantic-2.0[${PYTHON_USEDEP}]
		>=dev-python/pydantic-settings-2.0[${PYTHON_USEDEP}]
	' python3_14)
"
DEPEND="${RDEPEND}"
