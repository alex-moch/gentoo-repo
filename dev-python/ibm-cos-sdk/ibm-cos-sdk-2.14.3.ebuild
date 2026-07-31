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

# Pinned to 2.14.3, not PyPI's latest (2.16.2): dev-python/ibm-watsonx-ai
# real-pins ibm-cos-sdk<2.15.0,>=2.12.0, and this whole trio (ibm-cos-sdk,
# -core, -s3transfer) must move in lockstep at the same PV regardless (each
# other's own real pins are exact ==). Don't bump without checking
# ibm-watsonx-ai's ceiling first. See dev-python/ibm-cos-sdk-core for the
# separate jmespath ceiling deviation.
RDEPEND="
	~dev-python/ibm-cos-sdk-core-2.14.3[${PYTHON_USEDEP}]
	~dev-python/ibm-cos-sdk-s3transfer-2.14.3[${PYTHON_USEDEP}]
	>=dev-python/jmespath-0.10.0[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"
