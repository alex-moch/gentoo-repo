# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=setuptools

inherit distutils-r1 pypi

DESCRIPTION="Python SDK for the Spider Cloud web crawling/scraping API"
HOMEPAGE="
	https://github.com/spider-rs/spider-clients
	https://pypi.org/project/spider-client/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RESTRICT="test"

# Upstream stopped publishing an sdist starting with 0.1.90 (wheel-only
# releases); 0.1.88 is the newest version that still ships one.
RDEPEND="
	dev-python/aiohttp[${PYTHON_USEDEP}]
	dev-python/ijson[${PYTHON_USEDEP}]
	dev-python/requests[${PYTHON_USEDEP}]
	dev-python/tenacity[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"
