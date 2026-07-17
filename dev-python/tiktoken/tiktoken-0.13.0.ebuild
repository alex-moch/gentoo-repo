# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# Upstream doesn't commit a Cargo.lock (library-style crate). This CRATES
# list was generated with `cargo generate-lockfile` against the 0.13.0 tag's
# Cargo.toml, i.e. whatever crates.io considered "latest compatible" at
# packaging time -- re-generate on every bump rather than hand-editing.
RUST_MIN_VER="1.85"

CRATES="
	aho-corasick@1.1.4
	bit-set@0.8.0
	bit-vec@0.8.0
	bstr@1.13.0
	fancy-regex@0.17.0
	heck@0.5.0
	libc@0.2.186
	memchr@2.8.3
	once_cell@1.21.4
	portable-atomic@1.13.1
	proc-macro2@1.0.106
	pyo3-build-config@0.28.3
	pyo3-ffi@0.28.3
	pyo3-macros-backend@0.28.3
	pyo3-macros@0.28.3
	pyo3@0.28.3
	quote@1.0.46
	regex-automata@0.4.16
	regex-syntax@0.8.11
	regex@1.13.1
	rustc-hash@2.1.3
	serde_core@1.0.228
	serde_derive@1.0.228
	syn@2.0.119
	target-lexicon@0.13.5
	unicode-ident@1.0.24
"

DISTUTILS_EXT=1
DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit cargo distutils-r1 pypi

DESCRIPTION="A fast BPE tokeniser for use with OpenAI's models"
HOMEPAGE="
	https://github.com/openai/tiktoken
	https://pypi.org/project/tiktoken/
"
SRC_URI+=" ${CARGO_CRATE_URIS}"

LICENSE="MIT"
# Dependent crate licenses
LICENSE+="
	Apache-2.0 Apache-2.0-with-LLVM-exceptions MIT Unicode-3.0
"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	dev-python/regex[${PYTHON_USEDEP}]
	dev-python/requests[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"
BDEPEND="
	>=dev-python/setuptools-rust-1.5.2[${PYTHON_USEDEP}]
"

RESTRICT="test"

QA_FLAGS_IGNORED="/usr/lib/python.*/site-packages/tiktoken/.*\.so"
