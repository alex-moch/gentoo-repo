# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=poetry-core

inherit distutils-r1 pypi

DESCRIPTION="The LangChain Hub API client"
HOMEPAGE="
	https://pypi.org/project/langchainhub/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RESTRICT="test"

# Real requires_dist is packaging<25,>=23.2; the tree only has
# packaging-26.1/26.2, so the real ceiling is currently unsatisfiable --
# loosened, same class of deviation as the wcmatch floor relaxation
# documented in CLAUDE.md's semgrep bump procedure.
RDEPEND="
	>=dev-python/packaging-23.2[${PYTHON_USEDEP}]
	>=dev-python/requests-2[${PYTHON_USEDEP}]
	<dev-python/requests-3[${PYTHON_USEDEP}]
	>=dev-python/types-requests-2.31.0.2[${PYTHON_USEDEP}]
	<dev-python/types-requests-3.0.0.0[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"
