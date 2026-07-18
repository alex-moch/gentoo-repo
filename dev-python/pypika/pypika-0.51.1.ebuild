# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="A SQL query builder API for Python"
HOMEPAGE="
	https://github.com/kayak/pypika
	https://pypi.org/project/pypika/
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

# Real install_requires is just `typing_extensions>=4.5.0; python_version<'3.11'`
# -- irrelevant to every PYTHON_COMPAT target here (all >=3.12), so RDEPEND is
# empty.
RESTRICT="test"
