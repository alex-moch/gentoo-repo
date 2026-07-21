# Copyright 2021-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=setuptools

inherit distutils-r1 pypi

DESCRIPTION="Convert HTML to Markdown"
HOMEPAGE="
	https://github.com/matthewwithanm/python-markdownify
	https://pypi.org/project/markdownify/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	>=dev-python/beautifulsoup4-4.9[${PYTHON_USEDEP}]
	<dev-python/beautifulsoup4-5[${PYTHON_USEDEP}]
	>=dev-python/six-1.15[${PYTHON_USEDEP}]
	<dev-python/six-2[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"

BDEPEND="
	dev-python/setuptools-scm[${PYTHON_USEDEP}]
"

RESTRICT="test"
