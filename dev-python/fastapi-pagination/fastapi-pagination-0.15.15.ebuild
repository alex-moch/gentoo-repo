# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=hatchling

inherit distutils-r1 pypi

DESCRIPTION="Pagination integration for FastAPI"
HOMEPAGE="
	https://github.com/uriyyo/fastapi-pagination
	https://pypi.org/project/fastapi-pagination/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RESTRICT="test"

RDEPEND="
	>=dev-python/fastapi-0.93.0[${PYTHON_USEDEP}]
	>=dev-python/pydantic-1.9.1[${PYTHON_USEDEP}]
	>=dev-python/typing-extensions-4.8.0[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"
