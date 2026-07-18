# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=poetry-core

inherit distutils-r1 pypi

DESCRIPTION="A rate limiting extension for Starlette and FastAPI"
HOMEPAGE="
	https://github.com/laurents/slowapi
	https://pypi.org/project/slowapi/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RESTRICT="test"

RDEPEND="
	>=dev-python/limits-2.3[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"
