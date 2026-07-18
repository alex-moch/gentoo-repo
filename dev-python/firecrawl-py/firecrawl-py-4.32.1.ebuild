# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=setuptools

inherit distutils-r1 pypi

DESCRIPTION="Python SDK for the Firecrawl web scraping/crawling API"
HOMEPAGE="
	https://github.com/firecrawl/firecrawl
	https://pypi.org/project/firecrawl-py/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RESTRICT="test"

RDEPEND="
	dev-python/aiohttp[${PYTHON_USEDEP}]
	dev-python/httpx[${PYTHON_USEDEP}]
	dev-python/nest-asyncio[${PYTHON_USEDEP}]
	>=dev-python/pydantic-2.0[${PYTHON_USEDEP}]
	dev-python/python-dotenv[${PYTHON_USEDEP}]
	dev-python/requests[${PYTHON_USEDEP}]
	dev-python/websockets[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"

src_prepare() {
	distutils-r1_src_prepare

	# Upstream's [tool.setuptools.packages.find] has no exclude for the
	# top-level "tests" directory, so setuptools installs it as a stray
	# top-level package. Drop it; it's not needed (RESTRICT=test).
	rm -rf tests || die
}
