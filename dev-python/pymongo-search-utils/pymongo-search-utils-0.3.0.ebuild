# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=hatchling

inherit distutils-r1 pypi

DESCRIPTION="Utility library for working with vector search in MongoDB using PyMongo"
HOMEPAGE="
	https://github.com/mongodb-labs/pymongo-search-utils
	https://pypi.org/project/pymongo-search-utils/
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

RESTRICT="test"

RDEPEND="
	>=dev-python/pymongo-4.12.0[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"
