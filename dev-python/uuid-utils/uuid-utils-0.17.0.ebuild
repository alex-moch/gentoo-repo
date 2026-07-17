# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# Upstream declares no explicit rust-version; edition = "2024" needs >=1.85,
# and a transitive dependency already pushed GURU's 0.16.0 floor to 1.87.
# Re-verify against the rust.eclass QA notice from the first real build.
RUST_MIN_VER="1.87.0"

CRATES="
	anyhow@1.0.102
	atomic@0.6.1
	autocfg@1.5.1
	bitflags@2.13.0
	block-buffer@0.10.4
	bumpalo@3.20.3
	bytemuck@1.25.0
	cfg-if@1.0.4
	cfg_aliases@0.2.1
	chacha20@0.10.0
	cpufeatures@0.3.0
	crypto-common@0.1.7
	digest@0.10.7
	equivalent@1.0.2
	foldhash@0.1.5
	futures-core@0.3.32
	futures-task@0.3.32
	futures-util@0.3.32
	generic-array@0.14.7
	getrandom@0.4.2
	hashbrown@0.15.5
	hashbrown@0.17.1
	heck@0.5.0
	id-arena@2.3.0
	indexmap@2.14.0
	itoa@1.0.18
	js-sys@0.3.102
	leb128fmt@0.1.0
	libc@0.2.186
	log@0.4.32
	mac_address@1.1.8
	md-5@0.10.6
	memchr@2.8.2
	memoffset@0.9.1
	nix@0.29.0
	once_cell@1.21.4
	pin-project-lite@0.2.17
	portable-atomic@1.13.1
	prettyplease@0.2.37
	proc-macro2@1.0.106
	pyo3-build-config@0.29.0
	pyo3-ffi@0.29.0
	pyo3-macros-backend@0.29.0
	pyo3-macros@0.29.0
	pyo3@0.29.0
	quote@1.0.45
	r-efi@6.0.0
	rand@0.10.1
	rand_core@0.10.1
	rustversion@1.0.22
	semver@1.0.28
	serde@1.0.228
	serde_core@1.0.228
	serde_derive@1.0.228
	serde_json@1.0.150
	sha1_smol@1.0.1
	slab@0.4.12
	syn@2.0.117
	target-lexicon@0.13.5
	typenum@1.20.1
	unicode-ident@1.0.24
	unicode-xid@0.2.6
	uuid@1.23.4
	version_check@0.9.5
	wasip2@1.0.4+wasi-0.2.12
	wasip3@0.4.0+wasi-0.3.0-rc-2026-01-06
	wasm-bindgen-macro-support@0.2.125
	wasm-bindgen-macro@0.2.125
	wasm-bindgen-shared@0.2.125
	wasm-bindgen@0.2.125
	wasm-encoder@0.244.0
	wasm-metadata@0.244.0
	wasmparser@0.244.0
	winapi-i686-pc-windows-gnu@0.4.0
	winapi-x86_64-pc-windows-gnu@0.4.0
	winapi@0.3.9
	wit-bindgen-core@0.51.0
	wit-bindgen-rust-macro@0.51.0
	wit-bindgen-rust@0.51.0
	wit-bindgen@0.51.0
	wit-bindgen@0.57.1
	wit-component@0.244.0
	wit-parser@0.244.0
	zmij@1.0.21
"

DISTUTILS_EXT=1
DISTUTILS_USE_PEP517=maturin
PYTHON_COMPAT=( python3_{12..14} )

inherit cargo distutils-r1 pypi

DESCRIPTION="Fast, drop-in replacement for Python's uuid module, powered by Rust"
HOMEPAGE="
	https://aminalaee.github.io/uuid-utils/
	https://github.com/aminalaee/uuid-utils
	https://pypi.org/project/uuid-utils/
"
SRC_URI+=" ${CARGO_CRATE_URIS}"

LICENSE="BSD"
# Dependent crate licenses
LICENSE+="
	Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD MIT Unicode-3.0 ZLIB
"
SLOT="0"
KEYWORDS="~amd64"

BDEPEND=">=dev-util/maturin-1.14.0[${PYTHON_USEDEP}]"

RESTRICT="test"

QA_FLAGS_IGNORED="/usr/lib/python.*/site-packages/uuid_utils/.*\.so"
