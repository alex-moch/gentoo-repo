# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=setuptools

inherit distutils-r1 pypi

DESCRIPTION="IBM S3 Transfer Manager"
HOMEPAGE="
	https://github.com/IBM/ibm-cos-sdk-python-s3transfer
	https://pypi.org/project/ibm-cos-sdk-s3transfer/
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

RESTRICT="test"

# Pinned to 2.14.3, not PyPI's latest -- see dev-python/ibm-cos-sdk for why
# (ibm-watsonx-ai's real ceiling, not anything internal to this trio).
RDEPEND="
	~dev-python/ibm-cos-sdk-core-2.14.3[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"
