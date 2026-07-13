# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Application-level firewall for Linux using eBPF"
HOMEPAGE="https://obdev.at/products/littlesnitch-linux/"

_PV="${PV}"
_PKG_REV=1
_DLBASE="https://obdev.at/downloads/littlesnitch-linux"

# Always fetch the packaged archive for service files, docs, and metainfo.
# When USE=static, also fetch the musl binary and prefer it at install time.
SRC_URI="
	amd64? (
		${_DLBASE}/${PN}-${_PV}-${_PKG_REV}-x86_64.pkg.tar.zst
		static? ( ${_DLBASE}/${PN}-${_PV}-amd64-linux-musl.tar.gz )
	)
	arm64? (
		${_DLBASE}/${PN}-${_PV}-${_PKG_REV}-aarch64.pkg.tar.zst
		static? ( ${_DLBASE}/${PN}-${_PV}-arm64-linux-musl.tar.gz )
	)
	ppc64? (
		${_DLBASE}/${PN}-${_PV}-${_PKG_REV}-ppc64le.pkg.tar.zst
		static? ( ${_DLBASE}/${PN}-${_PV}-ppc64le-linux-musl.tar.gz )
	)
	riscv? (
		${_DLBASE}/${PN}-${_PV}-${_PKG_REV}-riscv64.pkg.tar.zst
		static? ( ${_DLBASE}/${PN}-${_PV}-riscv64-linux-musl.tar.gz )
	)
"

S="${WORKDIR}"

LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~ppc64 ~riscv"
IUSE="static"

RESTRICT="mirror strip"

RDEPEND="
	!static? ( sys-libs/glibc )
"

BDEPEND="
	app-arch/zstd
"

# Kernel requirements: >= 6.12, BTF, and function tracer support.
# We check at pkg_pretend and pkg_postinst since this is a binary package
# and the running kernel may differ from the installed sources.

CONFIG_CHECK="
	DEBUG_INFO_BTF
	FUNCTION_TRACER
"

WARNING_DEBUG_INFO_BTF="
Little Snitch requires a kernel built with BTF (BPF Type Format) support.
The directory /sys/kernel/btf/ must exist at runtime.
Set CONFIG_DEBUG_INFO_BTF=y in your kernel configuration.
Most distribution kernels already enable this.
"

WARNING_FUNCTION_TRACER="
Little Snitch uses BPF function tracing to identify executable paths.
Set CONFIG_FUNCTION_TRACER=y in your kernel configuration.
Most distribution kernels already enable this.
Note: as of version 1.0.4, Little Snitch can work without tracing,
but script identification will be degraded.
"

inherit linux-info systemd

pkg_pretend() {
	kernel_is -ge 6 12 || ewarn \
		"Little Snitch requires Linux kernel >= 6.12. Your running" \
		"kernel is $(uname -r). Please upgrade before starting the daemon."

	linux-info_pkg_setup
}

pkg_setup() {
	linux-info_pkg_setup
}

src_unpack() {
	# Determine the upstream architecture suffix.
	local arch
	case "${ARCH}" in
		amd64)  arch=x86_64  ;;
		arm64)  arch=aarch64  ;;
		ppc64)  arch=ppc64le  ;;
		riscv)  arch=riscv64  ;;
		*)      die "Unsupported architecture: ${ARCH}" ;;
	esac

	# .pkg.tar.zst is not a format Portage recognises, but GNU tar
	# auto-detects zstd compression.
	local pkg="${PN}-${PV}-${_PKG_REV}-${arch}.pkg.tar.zst"
	einfo "Unpacking ${pkg} ..."
	tar xf "${DISTDIR}/${pkg}" -C "${WORKDIR}" \
		|| die "Failed to unpack ${pkg}"

	if use static; then
		# musl archive uses a different arch naming scheme.
		local musl_arch
		case "${ARCH}" in
			amd64)  musl_arch=amd64   ;;
			arm64)  musl_arch=arm64   ;;
			ppc64)  musl_arch=ppc64le ;;
			riscv)  musl_arch=riscv64 ;;
		esac
		unpack "${PN}-${PV}-${musl_arch}-linux-musl.tar.gz"
	fi
}

src_install() {
	# When USE=static, the musl tarball extracts a bare "littlesnitch" binary
	# into WORKDIR. Prefer it over the one from the packaged archive.
	if use static; then
		dobin "${WORKDIR}/littlesnitch"
	else
		dobin usr/bin/littlesnitch
	fi

	# Service files and docs always come from the packaged archive.
	systemd_dounit usr/lib/systemd/system/littlesnitch.service

	doinitd etc/init.d/littlesnitch

	if [[ -f usr/share/doc/littlesnitch/copyright ]]; then
		dodoc usr/share/doc/littlesnitch/copyright
	fi

	insinto /usr/share/metainfo
	doins usr/share/metainfo/at.obdev.littlesnitch.metainfo.xml
}

pkg_postinst() {
	# Runtime check: is the currently running kernel actually BTF-capable?
	if [[ ! -d /sys/kernel/btf ]]; then
		ewarn ""
		ewarn "WARNING: /sys/kernel/btf/ does not exist on the running kernel."
		ewarn "Little Snitch will refuse to start without BTF support."
		ewarn ""
		ewarn "Either reboot into a BTF-enabled kernel, or rebuild your kernel"
		ewarn "with CONFIG_DEBUG_INFO_BTF=y."
		ewarn ""
	fi

	elog ""
	elog "To start Little Snitch:"
	elog ""
	elog "  OpenRC:  rc-service littlesnitch start"
	elog "  systemd: systemctl start littlesnitch"
	elog ""
	elog "To start at boot:"
	elog ""
	elog "  OpenRC:  rc-update add littlesnitch default"
	elog "  systemd: systemctl enable littlesnitch"
	elog ""
	elog "The web UI is served on http://localhost:3031/ by default."
	elog ""
	elog "Minimum kernel version: 6.12"
	elog "Required kernel options: CONFIG_DEBUG_INFO_BTF=y"
	elog "                         CONFIG_FUNCTION_TRACER=y"
	elog ""
}
