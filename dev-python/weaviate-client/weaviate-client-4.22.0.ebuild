# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=setuptools

inherit distutils-r1 pypi

DESCRIPTION="A python native Weaviate client"
HOMEPAGE="
	https://github.com/weaviate/weaviate-python-client
	https://pypi.org/project/weaviate-client/
"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"

RESTRICT="test"

RDEPEND="
	>=dev-python/authlib-1.6.7[${PYTHON_USEDEP}]
	<dev-python/authlib-2[${PYTHON_USEDEP}]
	>=dev-python/grpcio-1.59.5[${PYTHON_USEDEP}]
	<dev-python/grpcio-1.80.0[${PYTHON_USEDEP}]
	>=dev-python/httpx-0.26.0[${PYTHON_USEDEP}]
	<dev-python/httpx-0.29.0[${PYTHON_USEDEP}]
	>=dev-python/packaging-21[${PYTHON_USEDEP}]
	>=dev-python/protobuf-4.21.6[${PYTHON_USEDEP}]
	<dev-python/protobuf-7[${PYTHON_USEDEP}]
	>=dev-python/pydantic-2.12.0[${PYTHON_USEDEP}]
	<dev-python/pydantic-3[${PYTHON_USEDEP}]
	>=dev-python/validators-0.34.0[${PYTHON_USEDEP}]
	<dev-python/validators-1[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"
BDEPEND="
	dev-python/setuptools-scm[${PYTHON_USEDEP}]
"
