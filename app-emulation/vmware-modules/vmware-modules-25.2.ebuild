# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit linux-mod-r1

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

	insinto /usr/lib/modules-load.d
	newins - vmware.conf <<-EOF || die
		vmmon
		vmnet
		vmw_vmci
		vmw_vsock_vmci_transport
	EOF
}

pkg_postinst() {
	linux-mod-r1_pkg_postinst
}
