# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=setuptools

inherit distutils-r1 pypi

DESCRIPTION="Python SDK for the Firecrawl web scraping/crawling API"
HOMEPAGE="
	https://github.com/mendableai/firecrawl
	https://pypi.org/project/firecrawl-py/
"

# Upstream's pyproject.toml/classifiers confusingly say AGPLv3/GPLv3, but
# the sdist's actual LICENSE file text is plain MIT -- trusted over the
# contradictory declared metadata.
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RESTRICT="test"

# langflow-base pins firecrawl-py>=1.0.16,<2.0.0 -- a much older, simpler
# release than what was previously (wrongly) packaged here. requires_dist
# at 1.9.0 is just these five; no stray top-level "tests" dir to strip
# either, unlike the later 4.x series.
RDEPEND="
	dev-python/requests[${PYTHON_USEDEP}]
	dev-python/python-dotenv[${PYTHON_USEDEP}]
	dev-python/websockets[${PYTHON_USEDEP}]
	dev-python/nest-asyncio[${PYTHON_USEDEP}]
	>=dev-python/pydantic-2.10.3[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"
