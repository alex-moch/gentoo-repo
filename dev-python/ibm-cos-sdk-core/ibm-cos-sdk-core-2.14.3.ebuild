# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=setuptools

inherit distutils-r1 pypi

DESCRIPTION="Low-level, data-driven core of IBM SDK for Python"
HOMEPAGE="
	https://github.com/ibm/ibm-cos-sdk-python-core
	https://pypi.org/project/ibm-cos-sdk-core/
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

RESTRICT="test"

# Pinned to 2.14.3, not PyPI's latest -- see dev-python/ibm-cos-sdk for why
# (ibm-watsonx-ai's real ceiling, not anything internal to this trio).
#
# Real upstream pin is jmespath<=1.0.1,>=0.10.0 (unchanged as of the current
# 2.16.2 release too -- not something this bump happened to catch mid-move).
# This tree only carries jmespath-1.1.0, above the real ceiling, and no
# older jmespath ebuild exists to satisfy it -- same class of unverified
# deviation as the wcmatch floor relaxation documented in CLAUDE.md's
# semgrep bump procedure.
RDEPEND="
	>=dev-python/jmespath-0.10.0[${PYTHON_USEDEP}]
	>=dev-python/python-dateutil-2.9.0[${PYTHON_USEDEP}]
	<dev-python/python-dateutil-3[${PYTHON_USEDEP}]
	>=dev-python/requests-2.32.4[${PYTHON_USEDEP}]
	<dev-python/requests-3[${PYTHON_USEDEP}]
	>=dev-python/urllib3-2.5.0[${PYTHON_USEDEP}]
	<dev-python/urllib3-3[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"
