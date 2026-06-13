# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{10..15} )

inherit distutils-r1 pypi

DESCRIPTION="A small library that optimizes some niche ELF operations for debuggers"
HOMEPAGE="
	https://github.com/pwndbg/niche-elf
	https://pypi.org/project/niche-elf/
"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"

src_prepare() {
	distutils-r1_src_prepare

	# Upstream ships PEP 621 metadata but omits the [build-system] table, so
	# the PEP 517 build cannot determine a backend. Supply the standard
	# setuptools backend.
	grep -q '^\[build-system\]' pyproject.toml || cat >> pyproject.toml <<-EOF || die
		[build-system]
		requires = ["setuptools>=61.0"]
		build-backend = "setuptools.build_meta"
	EOF
}
