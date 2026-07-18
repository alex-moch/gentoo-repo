# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Python extension for MurmurHash (MurmurHash3)"
HOMEPAGE="
	https://github.com/hajimes/mmh3
	https://pypi.org/project/mmh3/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

# No core install_requires -- everything in requires_dist is gated behind an
# extra (test/lint/type/docs/benchmark/plot).
RESTRICT="test"
