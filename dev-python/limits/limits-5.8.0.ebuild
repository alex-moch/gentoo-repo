# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=hatchling

inherit distutils-r1 pypi

DESCRIPTION="Rate limiting utilities"
HOMEPAGE="
	https://github.com/alisaifee/limits
	https://pypi.org/project/limits/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RESTRICT="test"

RDEPEND="
	>=dev-python/deprecated-1.2[${PYTHON_USEDEP}]
	>=dev-python/packaging-21[${PYTHON_USEDEP}]
	dev-python/typing-extensions[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"
BDEPEND="
	dev-python/hatch-vcs[${PYTHON_USEDEP}]
"
