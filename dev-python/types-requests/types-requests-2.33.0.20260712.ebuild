# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=setuptools

inherit distutils-r1 pypi

DESCRIPTION="Typing stubs for requests"
HOMEPAGE="
	https://github.com/python/typeshed
	https://pypi.org/project/types-requests/
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

RESTRICT="test"

RDEPEND="
	>=dev-python/urllib3-2[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"
