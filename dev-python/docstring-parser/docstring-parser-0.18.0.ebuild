# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=hatchling

inherit distutils-r1 pypi

DESCRIPTION="Parse Python docstrings in reST, Google and Numpydoc format"
HOMEPAGE="
	https://github.com/rr-/docstring_parser
	https://pypi.org/project/docstring-parser/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RESTRICT="test"
