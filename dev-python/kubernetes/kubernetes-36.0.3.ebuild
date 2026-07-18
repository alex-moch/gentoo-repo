# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Official Python client library for kubernetes"
HOMEPAGE="
	https://github.com/kubernetes-client/python
	https://pypi.org/project/kubernetes/
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

# Real upstream RDEPEND (as declared in the officially published PKG-INFO /
# wheel METADATA) is the union of two files bundled in the sdist,
# `requirements.txt` (sync client) and `requirements-asyncio.txt` (the
# kubernetes.aio.* asyncio client) -- both unconditional, no extras marker.
# The sdist's own default setup.py only wires up requirements.txt (it's the
# repo's local dev entry point); the actual release build uses
# setup-release.py, which adds requirements-asyncio.txt on top and packages
# the kubernetes.aio submodule too -- see python_prepare_all() below, which
# swaps the two files so our build matches what's actually on PyPI.
#
# websocket-client's `!=0.40.0,!=0.41.*,!=0.42.*` and urllib3's `!=2.6.0`
# exclude old broken releases well below what's in the tree
# (websocket-client-1.9.0, urllib3-2.7.0) -- dropped as moot, matching how
# the main Gentoo tree's own reverse-deps on these packages (dev-python/docker,
# dev-python/jupyter-server) handle the same upstream exclusions.
RDEPEND="
	dev-python/certifi[${PYTHON_USEDEP}]
	>=dev-python/six-1.9.0[${PYTHON_USEDEP}]
	>=dev-python/python-dateutil-2.5.3[${PYTHON_USEDEP}]
	>=dev-python/pyyaml-6.0.3[${PYTHON_USEDEP}]
	>=dev-python/websocket-client-0.32.0[${PYTHON_USEDEP}]
	dev-python/requests[${PYTHON_USEDEP}]
	dev-python/requests-oauthlib[${PYTHON_USEDEP}]
	>=dev-python/urllib3-1.24.2[${PYTHON_USEDEP}]
	>=dev-python/durationpy-0.7[${PYTHON_USEDEP}]
	>=dev-python/aiohttp-3.13.5[${PYTHON_USEDEP}]
	<dev-python/aiohttp-4.0.0[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"

RESTRICT="test"

python_prepare_all() {
	# See RDEPEND comment above -- setup-release.py is what upstream
	# actually builds the published PyPI artifact with.
	cp -f setup-release.py setup.py || die

	distutils-r1_python_prepare_all
}
