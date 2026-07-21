# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=uv-build
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Python SDK for the Agent-User Interaction (AG-UI) Protocol"
HOMEPAGE="
	https://github.com/ag-ui-protocol/ag-ui
	https://pypi.org/project/ag-ui-protocol/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RESTRICT="test"

RDEPEND="
	>=dev-python/pydantic-2.11.2[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"
