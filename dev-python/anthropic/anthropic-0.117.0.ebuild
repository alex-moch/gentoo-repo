# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=hatchling

inherit distutils-r1 pypi

DESCRIPTION="The official Python library for the Anthropic API"
HOMEPAGE="
	https://github.com/anthropics/anthropic-sdk-python
	https://pypi.org/project/anthropic/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RESTRICT="test"

RDEPEND="
	>=dev-python/anyio-3.5.0[${PYTHON_USEDEP}]
	>=dev-python/distro-1.7.0[${PYTHON_USEDEP}]
	>=dev-python/docstring-parser-0.15[${PYTHON_USEDEP}]
	>=dev-python/httpx-0.25.0[${PYTHON_USEDEP}]
	>=dev-python/jiter-0.4.0[${PYTHON_USEDEP}]
	>=dev-python/pydantic-1.9.0[${PYTHON_USEDEP}]
	dev-python/sniffio[${PYTHON_USEDEP}]
	>=dev-python/typing-extensions-4.14[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"
BDEPEND="
	dev-python/hatch-fancy-pypi-readme[${PYTHON_USEDEP}]
"
