# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=poetry-core

inherit distutils-r1 pypi

DESCRIPTION="Dynamically generate pydantic models from JSON schema"
HOMEPAGE="
	https://github.com/hinthornw/dydantic
	https://pypi.org/project/dydantic/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RESTRICT="test"

RDEPEND="
	>=dev-python/pydantic-2[${PYTHON_USEDEP}]
	<dev-python/pydantic-3[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"
