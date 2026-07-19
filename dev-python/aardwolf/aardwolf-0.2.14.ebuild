# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_EXT=1
DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

# 0.2.14's rlers Cargo.toml jumped from pyo3 0.16.6 (what the ebuild this
# was forked from carried) to pyo3 0.27.2 -- regenerated fresh via
# `cargo generate-lockfile` (no Cargo.lock is shipped in the sdist)
# followed by `pycargoebuild` against aardwolf/utils/rlers/.
CRATES="
	autocfg@1.5.1
	byteorder@1.5.0
	heck@0.5.0
	indoc@2.0.7
	libc@0.2.186
	memoffset@0.9.1
	once_cell@1.21.4
	portable-atomic@1.14.0
	proc-macro2@1.0.106
	pyo3-build-config@0.27.2
	pyo3-ffi@0.27.2
	pyo3-macros-backend@0.27.2
	pyo3-macros@0.27.2
	pyo3@0.27.2
	quote@1.0.46
	rustversion@1.0.23
	syn@2.0.119
	target-lexicon@0.13.5
	unicode-ident@1.0.24
	unindent@0.2.4
"

inherit cargo distutils-r1 pypi

DESCRIPTION="Asynchronous RDP protocol implementation"
HOMEPAGE="https://github.com/skelsec/aardwolf"
SRC_URI+=" ${CARGO_CRATE_URIS}"

LICENSE="MIT Apache-2.0-with-LLVM-exceptions Unicode-3.0"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	>=dev-python/unicrypto-0.0.11[${PYTHON_USEDEP}]
	>=dev-python/asyauth-0.0.16[${PYTHON_USEDEP}]
	>=dev-python/asysocks-0.2.9[${PYTHON_USEDEP}]
	dev-python/tqdm[${PYTHON_USEDEP}]
	dev-python/colorama[${PYTHON_USEDEP}]
	dev-python/asn1crypto[${PYTHON_USEDEP}]
	dev-python/asn1tools[${PYTHON_USEDEP}]
	>=dev-python/pyperclip-1.8.2[${PYTHON_USEDEP}]
	>=dev-python/arc4-0.3.0[${PYTHON_USEDEP}]
	>=dev-python/pillow-9.0.0[${PYTHON_USEDEP}]
"

BDEPEND="
	dev-python/setuptools-rust[${PYTHON_USEDEP}]
"

DEPEND="${RDEPEND}"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

# https://github.com/skelsec/aardwolf/issues/21
# Rust does not respect CFLAGS/LDFLAGS
QA_FLAGS_IGNORED="usr/lib/python.*/site-packages/librlers.cpython-31.-x86_64-linux-gnu.so
.*/_rust.*
"

#https://github.com/skelsec/aardwolf/issues/29
python_install() {
	rm -r ${PN}/utils/rlers || die
	distutils-r1_python_install
	python_domodule aardwolf
}
