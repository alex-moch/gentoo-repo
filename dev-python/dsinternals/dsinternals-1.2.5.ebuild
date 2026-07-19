# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

DESCRIPTION="Directory Services Internals Library"
HOMEPAGE="https://github.com/p0dalirius/pydsinternals"
SRC_URI="https://github.com/p0dalirius/pydsinternals/archive/${PV}.tar.gz -> ${P}.gh.tar.gz"
S="${WORKDIR}/pydsinternals-${PV}"

# 1.2.5 has no sdist on PyPI (wheel-only release), hence building from
# the GitHub tag instead of the usual pypi.eclass fetch.
#
# LICENSE is MIT per the repo's own LICENSE file, not GPL-2 -- the
# ebuild this was forked from had it wrong.
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="test"

# setup.py declares pycryptodomex, but nothing in the source imports
# Crypto or Cryptodome (grepped) -- it uses OpenSSL and cryptography
# directly instead, and pycryptodomex isn't packaged in Gentoo anyway
# (same reasoning as dev-python/impacket's Cryptodome->Crypto
# workaround). Also fixes a bug in the source ebuild this was forked
# from, where two unconcatenated RDEPEND= assignments silently dropped
# pyopenssl even though X509Certificate2.py imports it.
RDEPEND="
	dev-python/pyopenssl[${PYTHON_USEDEP}]
	dev-python/cryptography[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

src_prepare() {
	rm -r tests || die
	distutils-r1_src_prepare
}
