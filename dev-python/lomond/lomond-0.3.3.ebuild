# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=setuptools

inherit distutils-r1 pypi

DESCRIPTION="Websocket client library"
HOMEPAGE="
	https://github.com/wildfoundry/dataplicity-lomond
	https://pypi.org/project/lomond/
"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"

RESTRICT="test"

RDEPEND="
	>=dev-python/six-1.10.0[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"
