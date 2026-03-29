# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit linux-mod-r1 udev

COMMIT="316e75e8db2505d66179cb8911a0bcaf5919610b"

DESCRIPTION="VMware Workstation kernel modules (vmmon, vmnet)"
HOMEPAGE="https://github.com/alex-moch/vmware-modules"
SRC_URI="https://github.com/alex-moch/vmware-modules/archive/${COMMIT}.tar.gz -> ${P}-${COMMIT}.tar.gz"
S="${WORKDIR}/vmware-modules-${COMMIT}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="acct-group/vmware"

CONFIG_CHECK="~HIGH_RES_TIMERS VMWARE_VMCI ~VMWARE_VMCI_VSOCKETS"

src_configure() {
	export LINUXINCLUDE="${KERNEL_DIR}/include"
}

src_compile() {
	local modlist=(
		vmmon=misc:vmmon-only
		vmnet=misc:vmnet-only
	)
	linux-mod-r1_src_compile
}

src_install() {
	linux-mod-r1_src_install

	local udevrules="${T}/60-vmware.rules"
	cat > "${udevrules}" <<-EOF
		KERNEL=="vmci",     GROUP="vmware", MODE="0660"
		KERNEL=="vmw_vmci", GROUP="vmware", MODE="0660"
		KERNEL=="vmmon",    GROUP="vmware", MODE="0660"
		KERNEL=="vsock",    GROUP="vmware", MODE="0660"
	EOF
	udev_dorules "${udevrules}"

	insinto /etc/modprobe.d
	newins - vmware.conf <<-EOF
		# Map VMware module aliases to in-kernel modules
		alias vmci vmw_vmci
		alias vsock vmw_vsock_vmci_transport
	EOF

	insinto /usr/lib/modules-load.d
	newins - vmware.conf <<-EOF
		vmmon
		vmnet
	EOF
}

pkg_postinst() {
	linux-mod-r1_pkg_postinst
	udev_reload
}

pkg_postrm() {
	udev_reload
}
