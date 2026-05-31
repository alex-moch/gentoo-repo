# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit linux-mod-r1

COMMIT="ba3a73bd88cf865c46799af911e31d90b030f2e1"

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
}

pkg_postinst() {
	linux-mod-r1_pkg_postinst
}
