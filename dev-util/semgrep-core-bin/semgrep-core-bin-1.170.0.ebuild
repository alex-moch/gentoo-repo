# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit pypi

DESCRIPTION="Prebuilt semgrep-core analysis engine, extracted from the official semgrep wheel"
HOMEPAGE="https://github.com/semgrep/semgrep"

# Upstream only publishes semgrep-core inside platform-tagged wheels (no
# sdist build path exists for it); this is the amd64/glibc manylinux wheel.
PY_TAG="cp310.cp311.cp312.cp313.cp314.py310.py311.py312.py313.py314"
ABI_TAG="none-manylinux_2_34_x86_64"

SRC_URI="$(pypi_wheel_url --unpack semgrep ${PV} ${PY_TAG} ${ABI_TAG})"
S="${WORKDIR}/semgrep-${PV}.data"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="~amd64"

BDEPEND="app-arch/unzip"

# Since upstream's manylinux build vendors its own copies of libcurl,
# libssl/libcrypto, libkrb5, tree-sitter, libunwind, elfutils, etc. (see
# purelib/semgrep/bin/libs/ in the wheel) rather than linking the host's,
# and several of those sonames (libtree-sitter.so.0.22, libunwind.so.8)
# don't match what this overlay's own dependency tree provides, semgrep-core
# is installed into a private libexec dir with its bundled libs alongside
# it, matching the $ORIGIN/libs RUNPATH baked into the binary. Do not try
# to relink it against system libs without re-verifying every soname.
QA_PREBUILT="usr/libexec/${PN}/*"

# Re-stripping this prebuilt OCaml binary (and its bundled libs) corrupts
# its version-info sections badly enough that ld.so throws spurious
# "no version information available" / "undefined symbol: , version"
# errors on some code paths (e.g. `-rpc` mode). Keep upstream's own strip
# level as-is.
RESTRICT="strip"

src_install() {
	local libexecdir="usr/libexec/${PN}"

	exeinto "/${libexecdir}"
	doexe purelib/semgrep/bin/semgrep-core

	exeinto "/${libexecdir}/libs"
	doexe purelib/semgrep/bin/libs/*.so*

	dosym -r "/${libexecdir}/semgrep-core" /usr/bin/semgrep-core
}
