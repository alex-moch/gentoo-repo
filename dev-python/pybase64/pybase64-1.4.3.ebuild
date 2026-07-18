# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Fast Base64 encoding/decoding using SIMD instructions"
HOMEPAGE="
	https://github.com/mayeut/pybase64
	https://pypi.org/project/pybase64/
"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="~amd64"

# No install_requires at all.
#
# The vendored libbase64 SIMD C extension is built by driving cmake from
# setup.py (see base64_build() / BuildExt in setup.py); without cmake
# available the build is *not* fatal -- setup.py marks the extension
# `optional=True` outside of CIBUILDWHEEL and silently falls back to
# src/pybase64/_fallback.py (a plain stdlib-base64 implementation). Depend on
# cmake anyway so we actually get the accelerated extension rather than
# silently degrading to the pure-Python path.
BDEPEND="
	dev-build/cmake
"

RESTRICT="test"
