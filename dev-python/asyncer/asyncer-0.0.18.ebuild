# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=pdm-backend

inherit distutils-r1 pypi

DESCRIPTION="Asyncer, async and await, focused on developer experience"
HOMEPAGE="
	https://github.com/fastapi/asyncer
	https://pypi.org/project/asyncer/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RESTRICT="test"

RDEPEND="
	>=dev-python/anyio-3.4.0[${PYTHON_USEDEP}]
	<dev-python/anyio-5[${PYTHON_USEDEP}]
	>=dev-python/sniffio-1.1[${PYTHON_USEDEP}]
	>=dev-python/typing-extensions-4.12.0[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"
