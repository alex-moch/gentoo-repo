# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=setuptools

inherit distutils-r1 pypi

DESCRIPTION="IBM watsonx.ai Python SDK"
HOMEPAGE="
	https://github.com/IBM/watsonx-ai-python-sdk
	https://pypi.org/project/ibm-watsonx-ai/
"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"

RESTRICT="test"

# Upstream splits its pandas floor by python_version (<2.4.0,>=0.24.2 for
# <3.14; >=2.3.3 with no ceiling for >=3.14) -- Portage atoms can't express
# that marker, and this tree only builds for python3_14, so only the
# >=3.14 branch applies here.
RDEPEND="
	dev-python/requests[${PYTHON_USEDEP}]
	>=dev-python/httpx-0.27[${PYTHON_USEDEP}]
	<dev-python/httpx-0.29[${PYTHON_USEDEP}]
	dev-python/urllib3[${PYTHON_USEDEP}]
	>=dev-python/pandas-2.3.3[${PYTHON_USEDEP}]
	<dev-python/pandas-3[${PYTHON_USEDEP}]
	dev-python/certifi[${PYTHON_USEDEP}]
	dev-python/lomond[${PYTHON_USEDEP}]
	dev-python/tabulate[${PYTHON_USEDEP}]
	dev-python/packaging[${PYTHON_USEDEP}]
	>=dev-python/ibm-cos-sdk-2.12.0[${PYTHON_USEDEP}]
	<dev-python/ibm-cos-sdk-2.15.0[${PYTHON_USEDEP}]
	dev-python/cachetools[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"
