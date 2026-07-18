# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=poetry-core

inherit distutils-r1 pypi

DESCRIPTION="Client library for the Qdrant vector search engine"
HOMEPAGE="
	https://github.com/qdrant/qdrant-client
	https://pypi.org/project/qdrant-client/
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

RESTRICT="test"

RDEPEND="
	>=dev-python/grpcio-1.41.0[${PYTHON_USEDEP}]
	>=dev-python/httpx-0.20.0[${PYTHON_USEDEP}]
	dev-python/h2[${PYTHON_USEDEP}]
	$(python_gen_cond_dep '
		>=dev-python/numpy-1.26[${PYTHON_USEDEP}]
	' python3_12)
	$(python_gen_cond_dep '
		>=dev-python/numpy-2.1.0[${PYTHON_USEDEP}]
	' python3_13)
	$(python_gen_cond_dep '
		>=dev-python/numpy-2.3.0[${PYTHON_USEDEP}]
	' python3_14)
	>=dev-python/portalocker-2.7.0[${PYTHON_USEDEP}]
	<dev-python/portalocker-4[${PYTHON_USEDEP}]
	>=dev-python/protobuf-3.20.0[${PYTHON_USEDEP}]
	>=dev-python/pydantic-1.10.8[${PYTHON_USEDEP}]
	>=dev-python/urllib3-1.26.14[${PYTHON_USEDEP}]
	<dev-python/urllib3-3[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"
