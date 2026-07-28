# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=hatchling

inherit distutils-r1 pypi

DESCRIPTION="Agent2Agent (A2A) protocol Python SDK"
HOMEPAGE="
	https://a2a-protocol.org/
	https://github.com/a2aproject/a2a-python
	https://pypi.org/project/a2a-sdk/
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

RESTRICT="test"

BDEPEND="
	dev-python/uv-dynamic-versioning[${PYTHON_USEDEP}]
"

# culsans is only pulled in for python_full_version < "3.13" upstream; this
# tree only targets python3_12 and newer with no sub-3.13 target enabled, so
# it's omitted rather than packaged for a branch nothing here builds.
#
# protobuf's real ceiling is <7 -- satisfied by dev-python/protobuf-6.33.6,
# which coexists in this tree alongside newer 7.x releases.
RDEPEND="
	>=dev-python/google-api-core-1.26.0[${PYTHON_USEDEP}]
	>=dev-python/googleapis-common-protos-1.70.0[${PYTHON_USEDEP}]
	>=dev-python/httpx-0.28.1[${PYTHON_USEDEP}]
	>=dev-python/json-rpc-1.15.0[${PYTHON_USEDEP}]
	>=dev-python/packaging-24.0[${PYTHON_USEDEP}]
	>=dev-python/protobuf-5.29.5[${PYTHON_USEDEP}]
	<dev-python/protobuf-7[${PYTHON_USEDEP}]
	>=dev-python/pydantic-2.11.3[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"
