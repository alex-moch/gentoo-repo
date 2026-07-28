# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Read resources from Python packages, a backport of importlib.resources"
HOMEPAGE="
	https://github.com/python/importlib_resources
	https://pypi.org/project/importlib-resources/
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

# Pinned to the last 6.x release deliberately -- 7.x onward adds a
# `coherent.licensed` build-time dependency (jaraco/skeleton#174) that isn't
# packaged anywhere in this tree (main Gentoo tree, this overlay, or Pentoo).
# 6.5.2 only needs plain setuptools + setuptools_scm, both already available.
# Real install_requires is just `zipp>=3.1.0; python_version<'3.10'`,
# irrelevant to every PYTHON_COMPAT target here (all >=3.12), so RDEPEND is
# empty. chromadb's own RDEPEND pulls this in unconditionally even though
# Python 3.12+ ships importlib.resources with feature parity in most cases --
# chromadb's code still imports the backport package by name.
BDEPEND="
	dev-python/setuptools-scm[${PYTHON_USEDEP}]
"

RESTRICT="test"
