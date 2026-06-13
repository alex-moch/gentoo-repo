# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
DISTUTILS_SINGLE_IMPL=1
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

DESCRIPTION="A GDB plug-in that makes debugging with GDB suck less"
HOMEPAGE="https://github.com/pwndbg/pwndbg"

if [[ ${PV} == "99999999" ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/pwndbg/pwndbg"
else
	MY_PV="${PV:0:4}.${PV:4:2}.${PV:6:2}"
	SRC_URI="https://github.com/pwndbg/pwndbg/archive/${MY_PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~arm64 ~x86"
	S="${WORKDIR}/${PN}-${MY_PV}"
fi

LICENSE="MIT"
SLOT="0"

RDEPEND="
	dev-debug/gdb[python,${PYTHON_SINGLE_USEDEP}]
	~dev-python/gdb-pt-dump-0.0.0_p20240401[${PYTHON_SINGLE_USEDEP}]
	$(python_gen_cond_dep '
		>=dev-libs/capstone-6.0.0_alpha5[python,${PYTHON_USEDEP}]
		>=dev-python/niche-elf-0.3.6[${PYTHON_USEDEP}]
		>=dev-python/psutil-7.0.0[${PYTHON_USEDEP}]
		>=dev-python/pycparser-3.0[${PYTHON_USEDEP}]
		>=dev-python/pyelftools-0.32[${PYTHON_USEDEP}]
		>=dev-python/pygments-2.19.2[${PYTHON_USEDEP}]
		>=dev-python/requests-2.32.5[${PYTHON_USEDEP}]
		>=dev-python/rich-14.1.0[${PYTHON_USEDEP}]
		>=dev-python/sortedcontainers-2.4.0[${PYTHON_USEDEP}]
		>=dev-python/tabulate-0.9.0[${PYTHON_USEDEP}]
		>=dev-python/typing-extensions-4.15.0[${PYTHON_USEDEP}]
		>=dev-util/pwntools-4.14.1[${PYTHON_USEDEP}]
		>=dev-util/ROPgadget-7.6[${PYTHON_USEDEP}]
		>=dev-util/unicorn-2.1.4[python,${PYTHON_USEDEP}]
	')
"

# Tests are architecture-specific (precompiled binaries)
RESTRICT="test"

src_prepare() {
	distutils-r1_src_prepare

	# Upstream vendors a forked capstone (the "capstone6pwndbg" module) and
	# imports from it directly. Point those imports at the system
	# dev-libs/capstone instead, which provides the same capstone 6.0.0 API.
	# The fork's only incompatible name is the RISC-V compressed mode, which
	# capstone calls CS_MODE_RISCV_C rather than CS_MODE_RISCVC.
	find . -name '*.py' -exec sed -i \
		-e 's/capstone6pwndbg/capstone/g' \
		-e 's/CS_MODE_RISCVC/CS_MODE_RISCV_C/g' \
		{} + || die "capstone de-vendor sed failed"
}

src_install() {
	distutils-r1_src_install

	insinto /usr/share/${PN}
	doins gdbinit.py

	python_optimize "${ED}"/usr/share/${PN}

	dodoc README.md
	dodoc -r docs
}

pkg_postinst() {
	if [[ -z "${REPLACING_VERSIONS}" ]]; then
		einfo "Usage:"
		einfo "    ~$ pwndbg <program>"
		einfo
		ewarn "Some pwndbg commands only work with libc debug symbols."
		ewarn "See also:"
		ewarn " * https://github.com/pentoo/pentoo-overlay/issues/521#issuecomment-548975884"
		ewarn " * https://sourceware.org/gdb/onlinedocs/gdb/Separate-Debug-Files.html"
		ewarn " * https://wiki.gentoo.org/wiki/Debugging"
	fi
}
