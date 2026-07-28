# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=setuptools

inherit distutils-r1 pypi

DESCRIPTION="IBM SDK for Python"
HOMEPAGE="
	https://github.com/ibm/ibm-cos-sdk-python
	https://pypi.org/project/ibm-cos-sdk/
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

RESTRICT="test"

# See dev-python/ibm-cos-sdk-core for the jmespath ceiling deviation.
RDEPEND="
	~dev-python/ibm-cos-sdk-core-2.14.3[${PYTHON_USEDEP}]
	~dev-python/ibm-cos-sdk-s3transfer-2.14.3[${PYTHON_USEDEP}]
	>=dev-python/jmespath-0.10.0[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"
