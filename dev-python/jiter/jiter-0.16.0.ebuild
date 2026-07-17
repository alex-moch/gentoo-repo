# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

RUST_MIN_VER="1.88.0"

# Upstream doesn't commit a Cargo.lock (library-style crate), so this CRATES
# list can't be copied from one. It's the real, non-dev dependency closure of
# crates/jiter-python for this target, verified against a fresh
# `cargo tree --package jiter-python -e no-dev` run on x86_64-linux -- i.e.
# with upstream's own [dev-dependencies] (criterion/codspeed/proptest bench
# and fuzz harnesses) and other-platform-only transitive deps of getrandom
# (r-efi, wasip2, wit-bindgen, portable-atomic) excluded. Re-verify the same
# way on every bump rather than hand-editing.
CRATES="
	ahash@0.8.12
	autocfg@1.5.1
	bitvec@1.1.1
	cfg-if@1.0.4
	funty@2.0.0
	getrandom@0.3.4
	heck@0.5.0
	lexical-parse-float@1.0.6
	lexical-parse-integer@1.0.6
	lexical-util@1.0.7
	libc@0.2.186
	num-bigint@0.4.6
	num-integer@0.1.46
	num-traits@0.2.19
	once_cell@1.21.4
	proc-macro2@1.0.106
	pyo3@0.29.0
	pyo3-build-config@0.29.0
	pyo3-ffi@0.29.0
	pyo3-macros@0.29.0
	pyo3-macros-backend@0.29.0
	quote@1.0.46
	radium@0.7.0
	smallvec@1.15.2
	syn@2.0.118
	tap@1.0.1
	target-lexicon@0.13.5
	unicode-ident@1.0.24
	version_check@0.9.5
	wyz@0.5.1
	zerocopy@0.8.52
"

DISTUTILS_EXT=1
DISTUTILS_USE_PEP517=maturin
PYTHON_COMPAT=( python3_{12..14} )

inherit cargo distutils-r1 pypi

DESCRIPTION="Fast iterable JSON parser"
HOMEPAGE="
	https://github.com/pydantic/jiter
	https://pypi.org/project/jiter/
"
SRC_URI+=" ${CARGO_CRATE_URIS}"

LICENSE="MIT"
# Dependent crate licenses
LICENSE+="
	Apache-2.0 Apache-2.0-with-LLVM-exceptions MIT MPL-2.0 Unicode-3.0
"
SLOT="0"
KEYWORDS="~amd64"

BDEPEND=">=dev-util/maturin-1.14.0[${PYTHON_USEDEP}]"

RESTRICT="test"

QA_FLAGS_IGNORED="/usr/lib/python.*/site-packages/jiter/.*\.so"
