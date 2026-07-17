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
	<dev-python/tenacity-9.2[${PYTHON_USEDEP}]
	>=dev-python/typing-extensions-4.14.0[${PYTHON_USEDEP}]
	>=dev-python/websockets-13.0.0[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"

src_prepare() {
	distutils-r1_src_prepare

	# Upstream's pyproject.toml has a [build-system] table but omits the
	# build-backend key, so the PEP 517 build cannot determine a backend.
	# Insert the standard setuptools backend into the existing table
	# (matching dev-python/niche-elf's fix for the same upstream gap).
	grep -q '^build-backend' pyproject.toml || sed -i \
		'/^\[build-system\]/a build-backend = "setuptools.build_meta"' \
		pyproject.toml || die
}
