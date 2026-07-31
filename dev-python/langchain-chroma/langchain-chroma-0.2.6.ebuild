# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=pdm-backend
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="An integration package connecting Chroma and LangChain"
HOMEPAGE="
	https://github.com/langchain-ai/langchain/tree/master/libs/partners/chroma
	https://pypi.org/project/langchain-chroma/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

# langflow-base pins langchain-chroma~=0.2.6 (i.e. >=0.2.6,<0.3) -- PyPI's
# latest is 1.1.0, well past the real ceiling. Don't bump past 0.2.x.
#
# Real dependencies is just these three; the numpy floor is version-gated
# (>=1.26.0 on python<3.13, >=2.1.0 on python>=3.13) -- collapsed to the
# stricter unconditional 2.1.0 floor since Portage can't express a
# per-python-target floor in one RDEPEND, and the tree's numpy is already
# well above it either way.
RDEPEND="
	>=dev-python/langchain-core-0.3.76[${PYTHON_USEDEP}]
	>=dev-python/numpy-2.1.0[${PYTHON_USEDEP}]
	>=dev-python/chromadb-1.0.20[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"

RESTRICT="test"
