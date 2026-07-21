# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=hatchling

inherit distutils-r1 pypi

DESCRIPTION="Utility tool for converting various files to Markdown"
HOMEPAGE="
	https://github.com/microsoft/markitdown
	https://pypi.org/project/markitdown/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

# Core (non-extra) install only. Upstream's large optional-extras surface
# (pptx, docx, xlsx, xls, pdf, outlook, audio-transcription,
# youtube-transcription, az-doc-intel, az-content-understanding, all) each
# pull in their own document-format-specific converter stack and are
# deliberately not packaged here -- lfx's dependency on markitdown is a
# bare `markitdown>=0.1.4,<2.0.0`, which only needs the core install below.
RDEPEND="
	dev-python/beautifulsoup4[${PYTHON_USEDEP}]
	dev-python/charset-normalizer[${PYTHON_USEDEP}]
	dev-python/defusedxml[${PYTHON_USEDEP}]
	>=dev-python/magika-0.6.1[${PYTHON_USEDEP}]
	<dev-python/magika-0.7[${PYTHON_USEDEP}]
	dev-python/markdownify[${PYTHON_USEDEP}]
	dev-python/requests[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"

RESTRICT="test"
