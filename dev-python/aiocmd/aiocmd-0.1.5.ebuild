# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Coroutine-based CLI generator using prompt_toolkit"
HOMEPAGE="https://github.com/KimiNewt/aiocmd"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND=">=dev-python/prompt-toolkit-3.0.0[${PYTHON_USEDEP}]"
DEPEND="${RDEPEND}"
