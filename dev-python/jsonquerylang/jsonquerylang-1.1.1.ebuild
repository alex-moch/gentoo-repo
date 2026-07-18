# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=setuptools

inherit distutils-r1 pypi

DESCRIPTION="A lightweight, flexible, and expandable JSON query language"
HOMEPAGE="
	https://github.com/jsonquerylang/jsonquery-python
	https://jsonquerylang.org/
	https://pypi.org/project/jsonquerylang/
"

LICENSE="ISC"
SLOT="0"
KEYWORDS="~amd64"

RESTRICT="test"

# langflow-base pins jsonquerylang>=1.1.1,<2.0.0 -- 1.1.1's setup.py has
# install_requires=[]; the dev-python/regex dependency was only added in
# the 2.x series.
