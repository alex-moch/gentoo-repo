# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=setuptools

inherit distutils-r1 pypi

DESCRIPTION="Google Gen AI SDK for the Gemini Developer and Vertex AI APIs"
HOMEPAGE="
	https://github.com/googleapis/python-genai
	https://pypi.org/project/google-genai/
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

RESTRICT="test"

RDEPEND="
	>=dev-python/anyio-4.8.0[${PYTHON_USEDEP}]
	>=dev-python/distro-1.7.0[${PYTHON_USEDEP}]
	>=dev-python/google-auth-2.48.1[${PYTHON_USEDEP}]
	>=dev-python/httpx-0.28.1[${PYTHON_USEDEP}]
	>=dev-python/pydantic-2.12.5[${PYTHON_USEDEP}]
	>=dev-python/requests-2.28.1[${PYTHON_USEDEP}]
	dev-python/sniffio[${PYTHON_USEDEP}]
	>=dev-python/tenacity-8.2.3[${PYTHON_USEDEP}]
	>=dev-python/typing-extensions-4.14.0[${PYTHON_USEDEP}]
	>=dev-python/websockets-13.0.0[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"

src_prepare() {
	distutils-r1_src_prepare

	# Upstream ships setup.cfg but no setup.py and no build-backend key in
	# pyproject.toml, so gpep517 can't determine a backend at all (the
	# eclass's legacy-setuptools fallback only kicks in when setup.py
	# exists). Add the trivial stub setup.cfg-driven packages expect.
	cat <<-EOF > setup.py || die
	from setuptools import setup
	setup()
	EOF
}
