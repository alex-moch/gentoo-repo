# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{13..15} )

inherit desktop edo pam python-any-r1 readme.gentoo-r1 systemd xdg

MY_YEAR=$(ver_cut 1)
MY_HALF=$(ver_cut 2)
MY_UPDATE=$(ver_cut 3)
PV_BUILD=$(ver_cut 4)

MY_RELEASE="${MY_YEAR}H${MY_HALF}"
[[ ${MY_UPDATE} -gt 0 ]] && MY_RELEASE+="u${MY_UPDATE}"

MY_PN="VMware-Workstation-Full"
MY_P="${MY_PN}-${MY_RELEASE}-${PV_BUILD}"
PV_MODULES="$(ver_cut 1-2)"

VMWARE_FUSION_VER="26.0.0/25388279"
SYSTEMD_COMMIT="1f4952c6200459672f874c0c222e5f18a9f10c48"
UNLOCKER_VERSION="3.1.3"

VM_INSTALL_DIR="/opt/vmware"

DESCRIPTION="VMware Workstation Pro — desktop hypervisor"
HOMEPAGE="https://www.vmware.com/products/desktop-hypervisor/workstation-and-fusion"
SRC_URI="
	${MY_P}.x86_64.bundle
	macos-guests? (
		https://github.com/BDisp/unlocker/archive/${UNLOCKER_VERSION}.tar.gz
			-> unlocker-${UNLOCKER_VERSION}.tar.gz
		https://packages-prod.broadcom.com/tools/frozen/darwin/darwin.iso
	)
	systemd? (
		https://github.com/alex-moch/vmware-systemd/archive/${SYSTEMD_COMMIT}.tar.gz
			-> vmware-systemd-${SYSTEMD_COMMIT}.tgz
	)
"
S="${WORKDIR}/extracted"

LICENSE="GPL-2 GPL-3 MIT-with-advertising vmware"
SLOT="0"
KEYWORDS="~amd64"
IUSE="doc macos-guests +modules ovftool systemd vix"
IUSE+="
	$(printf 'vmware_guests_%s ' \
		darwin linux linuxpreglibc25 netware solaris windows winpre2k winprevista)
"
REQUIRED_USE="vmware_guests_darwin? ( macos-guests )"

RESTRICT="fetch mirror strip"

RDEPEND="
	dev-db/sqlite:3
	dev-libs/dbus-glib
	dev-libs/gmp:0
	dev-libs/icu:=
	dev-libs/json-c:=
	dev-libs/libxml2-compat:2
	dev-libs/nettle:0
	gnome-base/dconf
	media-gfx/graphite2
	media-libs/alsa-lib
	media-libs/libvorbis
	media-libs/mesa
	media-plugins/alsa-plugins[speex]
	net-dns/libidn:=
	net-libs/gnutls:=
	sys-apps/tcp-wrappers
	sys-apps/util-linux
	sys-auth/polkit
	sys-fs/fuse:3
	virtual/libcrypt:=
	x11-libs/libXcursor
	x11-libs/libXinerama
	x11-libs/libXxf86vm
	x11-libs/libdrm
	x11-libs/libxshmfence
	x11-libs/startup-notification
	x11-libs/xcb-util
	x11-themes/hicolor-icon-theme
	modules? ( ~app-emulation/vmware-modules-${PV_MODULES} )
"
BDEPEND="
	${PYTHON_DEPS}
	app-admin/chrpath
	app-arch/unzip
"

QA_TEXTRELS="
	opt/vmware/lib/vmware/bin/vmware-vmx
	opt/vmware/lib/vmware/bin/vmware-vmx-debug
	opt/vmware/lib/vmware/bin/vmware-vmx-stats
"

_vmware_guest_dirname() {
	case ${1} in
		linuxpreglibc25) echo "linuxPreGlibc25" ;;
		winpre2k)        echo "winPre2k" ;;
		winprevista)     echo "winPreVista" ;;
		*)               echo "${1}" ;;
	esac
}

_vmware_doexe_ifexists() {
	local dest=$1
	shift
	local f

	exeinto "${dest}"
	for f in "$@"; do
		[[ -e ${f} ]] && doexe "${f}"
	done
}

_vmware_dobin_ifexists() {
	local f
	for f in "$@"; do
		[[ -e ${f} ]] && dobin "${f}"
	done
}

_vmware_fperms_ifexists() {
	local mode=$1
	shift
	local p

	for p in "$@"; do
		[[ -e ${ED}${p} || -L ${ED}${p} ]] && fperms "${mode}" "${p}"
	done
}

pkg_nofetch() {
	einfo "Please download ${MY_P}.x86_64.bundle from"
	einfo "  ${HOMEPAGE}"
	einfo "and place it in your DISTDIR."
}

src_unpack() {
	local a

	for a in ${A}; do
		if [[ ${a} == *.bundle ]]; then
			edo cp "${DISTDIR}/${a}" "${WORKDIR}"
		else
			unpack "${a}"
		fi
	done

	export LC_ALL=C
	edo sh "${WORKDIR}/${MY_P}.x86_64.bundle" \
		--console --required --eulas-agreed -x extracted

	if ! use vix; then
		rm -rf extracted/vmware-vix-core extracted/vmware-vix-lib-Workstation* || die
	fi

	if use vmware_guests_darwin; then
		edo mkdir -p extracted/vmware-tools-darwin
		edo cp "${DISTDIR}/darwin.iso" extracted/vmware-tools-darwin/
	fi

	rm -rf extracted/vmware-vmx/lib/lib/libstdc++.so.6 || die
}

src_prepare() {
	default

	if [[ -e vmware-network-editor/lib/libvmware-netcfg.so ]]; then
		edo mkdir -p vmware-network-editor/lib/lib
		edo mv vmware-network-editor/lib/libvmware-netcfg.so \
			vmware-network-editor/lib/lib/
	fi

	# Intentional Gentoo deviation: modules are provided by app-emulation/vmware-modules.
	rm -f */bin/vmware-modconfig || die
	rm -rf */lib/modules/binary || die

	# Intentional Gentoo deviation: do not install vendor init integration.
	rm -f vmware-installer/bin/configure-initscript.sh || die

	if use ovftool; then
		edo chrpath -d vmware-ovftool/libcurl.so.4
	fi

	if use macos-guests; then
		# Redirect unlocker writes into the staging image. EPREFIX-only
		# rewrites would point at the live `/opt/vmware/...` tree, which
		# is outside the sandbox.
		sed -i \
			-e "s#vmx_path = '/usr#vmx_path = '${ED%/}${VM_INSTALL_DIR}#" \
			-e "s#os.path.isfile('/usr#os.path.isfile('${ED%/}${VM_INSTALL_DIR}#" \
			-e "s#vmwarebase = '/usr#vmwarebase = '${ED%/}${VM_INSTALL_DIR}#" \
			"${WORKDIR}/unlocker-${UNLOCKER_VERSION}/unlocker.py" || die
	fi

	DOC_CONTENTS="
/etc/env.d is updated during ${PN} installation. Please run:\\n
'env-update && source /etc/profile'\\n
Before you can use ${PN}, you must configure a default network setup.
You can do this by running 'emerge --config ${PN}'.\\n
To use ${PN}, your user must be in the vmware group.\\n"
}

src_install() {
	local vmware_installer_version
	vmware_installer_version=$(grep -oPm1 '(?<=<version>)[^<]+' vmware-installer/manifest.xml) || die

	into "${VM_INSTALL_DIR}"

	# Top-level real binaries.
	_vmware_dobin_ifexists \
		vmware-vmx/bin/vmnet-bridge \
		vmware-vmx/bin/vmnet-dhcpd \
		vmware-vmx/bin/vmnet-natd \
		vmware-vmx/bin/vmnet-netifup \
		vmware-vmx/bin/vmnet-sniffer \
		vmware-vmx/bin/vmware-collect-host-support-info \
		vmware-vmx/bin/vmware-gksu \
		vmware-vmx/bin/vmware-networks \
		vmware-vmx/bin/vmware-ping \
		vmware-workstation/bin/vmss2core \
		vmware-workstation/bin/vmware \
		vmware-workstation/bin/vmware-tray \
		vmware-workstation/bin/vmware-vdiskmanager \
		vmware-player-app/bin/vmplayer \
		vmware-player-app/bin/vmware-license-check.sh \
		vmware-player-app/bin/vmware-license-enter.sh \
		vmware-vprobe/bin/vmware-vprobe

	dosbin vmware-vmx/sbin/vmware-authd vmware-vmx/sbin/vmware-authdlauncher

	# Main VMware library tree. Player libs and runtime bits live under
	# `vmware-other-apps/lib/` since 26H1; `vmware-player-app/` is gone.
	insinto "${VM_INSTALL_DIR}/lib/vmware"
	doins -r \
		vmware-network-editor/lib/. \
		vmware-other-apps/lib/. \
		vmware-vmx/lib/. \
		vmware-vprobe/lib/. \
		vmware-workstation/lib/. \
		vmware-vmx/roms

	# Match vendor runtime layout for binaries that may not already be present
	# under lib/vmware/bin in the extracted payload.
	_vmware_doexe_ifexists "${VM_INSTALL_DIR}/lib/vmware/bin" \
		vmware-usbarbitrator/bin/vmware-usbarbitrator \
		vmware-vix-core/bin/vmrun

	# Remove bundled/unused libs that should not be installed.
	rm -rf \
		"${ED}${VM_INSTALL_DIR}/lib/vmware/libnfc-types.so" \
		"${ED}${VM_INSTALL_DIR}/lib/vmware/libsoclient.so" \
		"${ED}${VM_INSTALL_DIR}/lib/vmware/libvim-types.so" \
		"${ED}${VM_INSTALL_DIR}/lib/vmware/libvmacore.so" \
		"${ED}${VM_INSTALL_DIR}/lib/vmware/libvmomi.so" \
		"${ED}${VM_INSTALL_DIR}/lib/vmware/libvmware-hostd.so" \
		"${ED}${VM_INSTALL_DIR}/lib/vmware/libvmware-wssc-adminTool.so" \
		"${ED}${VM_INSTALL_DIR}/lib/vmware/diskLibWrapper.so" \
		"${ED}${VM_INSTALL_DIR}/lib/vmware/lib/libstdc++.so.6" \
		"${ED}${VM_INSTALL_DIR}/lib/vmware/lib/libxcb.so.1" || die

	local lib_xcb_cds="${ED}${VM_INSTALL_DIR}/lib/vmware-installer/${vmware_installer_version}/cdsHelper/lib/libxcb.so.1"
	[[ -e ${lib_xcb_cds} ]] && rm -f "${lib_xcb_cds}"

	# VMware installer infrastructure.
	insinto "${VM_INSTALL_DIR}/lib/vmware-installer/${vmware_installer_version}"
	doins -r vmware-installer/{cdsHelper,vmis,vmis-launcher,vmware-cds-helper,vmware-installer,vmware-installer.py,python}
	[[ -d vmware-installer/sopython ]] && doins -r vmware-installer/sopython

	local lib_dynload="${ED}${VM_INSTALL_DIR}/lib/vmware-installer/${vmware_installer_version}/python/lib/lib-dynload"
	rm -f \
		"${lib_dynload}/_bz2.cpython-310-x86_64-linux-gnu.so" \
		"${lib_dynload}/_gdbm.cpython-310-x86_64-linux-gnu.so" \
		"${lib_dynload}/"*_failed.so || die

	if compgen -G "${lib_dynload}/*.so" >/dev/null; then
		chrpath -k -r '/../lib:$ORIGIN/../lib' \
			"${lib_dynload}/"*.so \
			>/dev/null || die "chrpath for lib-dynload failed"
	fi

	_vmware_fperms_ifexists 0755 \
		"${VM_INSTALL_DIR}/lib/vmware-installer/${vmware_installer_version}/vmis-launcher" \
		"${VM_INSTALL_DIR}/lib/vmware-installer/${vmware_installer_version}/cdsHelper" \
		"${VM_INSTALL_DIR}/lib/vmware-installer/${vmware_installer_version}/vmware-installer"

	dosym ../lib/vmware-installer/"${vmware_installer_version}"/vmware-installer \
		${VM_INSTALL_DIR}/bin/vmware-installer

	insinto /etc/vmware-installer
	doins vmware-installer/bootstrap
	sed -i \
		-e "s/@@VERSION@@/${vmware_installer_version}/" \
		-e "s,@@VMWARE_INSTALLER@@,${VM_INSTALL_DIR}/lib/vmware-installer/${vmware_installer_version}," \
		"${ED}/etc/vmware-installer/bootstrap" || die

	# Desktop integration. Player was removed in 26H1; only Workstation
	# and the network editor UI ship desktop / appdata files now.
	insinto /usr/share/metainfo
	doins vmware-workstation/share/appdata/vmware-workstation.appdata.xml

	domenu vmware-workstation/share/applications/vmware-workstation.desktop
	[[ -e vmware-network-editor-ui/share/applications/vmware-netcfg.desktop ]] && \
		domenu vmware-network-editor-ui/share/applications/vmware-netcfg.desktop

	local size
	for size in 16 22 24 32 48 256; do
		[[ -e vmware-workstation/share/icons/hicolor/${size}x${size}/apps/vmware-workstation.png ]] && \
			doicon -s "${size}" vmware-workstation/share/icons/hicolor/${size}x${size}/apps/vmware-workstation.png
		[[ -e vmware-network-editor-ui/share/icons/hicolor/${size}x${size}/apps/vmware-netcfg.png ]] && \
			doicon -s "${size}" vmware-network-editor-ui/share/icons/hicolor/${size}x${size}/apps/vmware-netcfg.png
	done

	dosym ../icons/hicolor/256x256/apps/vmware-workstation.png /usr/share/pixmaps/vmware-workstation.png
	[[ -e "${ED}/usr/share/icons/hicolor/256x256/apps/vmware-netcfg.png" ]] && \
		dosym ../icons/hicolor/256x256/apps/vmware-netcfg.png /usr/share/pixmaps/vmware-netcfg.png

	if [[ -e "${ED}${VM_INSTALL_DIR}/lib/vmware/libconf/etc/gtk-3.0/gdk-pixbuf.loaders" ]]; then
		sed -i \
			-e "s:@@LIBCONF_DIR@@:${EPREFIX}${VM_INSTALL_DIR}/lib/vmware/libconf:g" \
			"${ED}${VM_INSTALL_DIR}/lib/vmware/libconf/etc/gtk-3.0/gdk-pixbuf.loaders" || die
	fi

	sed -i \
		-e "s:@@BINARY@@:${EPREFIX}${VM_INSTALL_DIR}/bin/vmware:g" \
		-e "/^Encoding/d" \
		"${ED}/usr/share/applications/vmware-workstation.desktop" || die

	[[ -e "${ED}/usr/share/applications/vmware-netcfg.desktop" ]] && \
		sed -i \
			-e "s:@@BINARY@@:${EPREFIX}${VM_INSTALL_DIR}/bin/vmware-netcfg:g" \
			-e "/^Encoding/d" \
			"${ED}/usr/share/applications/vmware-netcfg.desktop" || die

	# Setup helper.
	[[ -e vmware-player-setup/vmware-config ]] && \
		_vmware_doexe_ifexists "${VM_INSTALL_DIR}/lib/vmware/setup" \
			vmware-player-setup/vmware-config

	# Documentation.
	docompress -x /usr/share/doc/${PF}
	[[ -e vmware-workstation/doc/EULA ]] && dodoc vmware-workstation/doc/EULA

	if use ovftool; then
		insinto /usr/lib/vmware-ovftool
		[[ -e vmware-ovftool/vmware.eula ]] && doins vmware-ovftool/vmware.eula
	fi

	if use doc; then
		[[ -d vmware-workstation/doc ]] && dodoc -r vmware-workstation/doc
		[[ -d vmware-player-app/doc ]] && dodoc -r vmware-player-app/doc
		[[ -d vmware-vix-core/doc ]] && dodoc -r vmware-vix-core/doc
	fi

	# PAM and FUSE.
	pamd_mimic_system vmware-authd auth account

	insinto /etc/modprobe.d
	newins vmware-vmx/etc/modprobe.d/modprobe-vmware-fuse.conf vmware-fuse.conf

	# VIX API.
	if use vix; then
		insinto "${VM_INSTALL_DIR}/lib/vmware-vix"
		doins -r vmware-vix-core/lib/.
		# Backcompat dir name encodes the VIX API ABI (e.g. 1700), not the
		# Workstation marketing year — VMware freezes ABIs across releases.
		doins -r vmware-vix-lib-Workstation*/lib/.

		dosym vmware-vix/libvixAllProducts.so ${VM_INSTALL_DIR}/lib/libvixAllProducts.so

		insinto /usr/include/vmware-vix
		doins vmware-vix-core/include/vix.h
		doins vmware-vix-core/include/vm_basic_types.h
	fi

	# OVF Tool.
	if use ovftool; then
		insinto "${VM_INSTALL_DIR}/lib/vmware-ovftool"
		doins -r vmware-ovftool/.

		chmod 0755 \
			"${ED}${VM_INSTALL_DIR}/lib/vmware-ovftool/ovftool" \
			"${ED}${VM_INSTALL_DIR}/lib/vmware-ovftool/ovftool.bin" || die

		sed -i 's/readlink/readlink -f/' \
			"${ED}${VM_INSTALL_DIR}/lib/vmware-ovftool/ovftool" || die

		dosym ../lib/vmware-ovftool/ovftool ${VM_INSTALL_DIR}/bin/ovftool
	fi

	# appLoader dispatch symlinks inside lib/vmware/bin.
	# Intentional Gentoo deviation: omit vendor modconfig wrappers.
	local tool
	for tool in \
		licenseTool \
		vmplayer vmware vmware-app-control vmware-enter-serial vmware-fuseUI \
		vmware-gksu vmware-mount vmware-netcfg vmware-setup-helper \
		vmware-tray vmware-vmblock-fuse vmware-vprobe vmware-zenity
	do
		dosym appLoader "${VM_INSTALL_DIR}/lib/vmware/bin/${tool}"
	done

	# Top-level convenience links matching vendor runtime layout where applicable.
	[[ -e ${ED}${VM_INSTALL_DIR}/lib/vmware/bin/vmcli ]] && \
		dosym ../lib/vmware/bin/vmcli ${VM_INSTALL_DIR}/bin/vmcli

	[[ -e ${ED}${VM_INSTALL_DIR}/lib/vmware/bin/vmware-fuseUI ]] && \
		dosym ../lib/vmware/bin/vmware-fuseUI ${VM_INSTALL_DIR}/bin/vmware-fuseUI

	[[ -e ${ED}${VM_INSTALL_DIR}/lib/vmware/bin/vmware-mount ]] && \
		dosym ../lib/vmware/bin/vmware-mount ${VM_INSTALL_DIR}/bin/vmware-mount

	[[ -e ${ED}${VM_INSTALL_DIR}/lib/vmware/bin/vmware-netcfg ]] && \
		dosym ../lib/vmware/bin/vmware-netcfg ${VM_INSTALL_DIR}/bin/vmware-netcfg

	[[ -e ${ED}${VM_INSTALL_DIR}/lib/vmware/bin/vmware-usbarbitrator ]] && \
		dosym ../lib/vmware/bin/vmware-usbarbitrator ${VM_INSTALL_DIR}/bin/vmware-usbarbitrator

	[[ -e ${ED}${VM_INSTALL_DIR}/lib/vmware/bin/appLoader ]] && \
		dosym ../lib/vmware/bin/appLoader ${VM_INSTALL_DIR}/bin/vmrest

	use vix && [[ -e ${ED}${VM_INSTALL_DIR}/lib/vmware/bin/appLoader ]] && \
		dosym ../lib/vmware/bin/appLoader ${VM_INSTALL_DIR}/bin/vmrun

	dosym ../../opt/vmware/lib/vmware/icu /etc/vmware/icu

	# Permissions.
	_vmware_fperms_ifexists 0755 \
		${VM_INSTALL_DIR}/lib/vmware/bin/appLoader \
		${VM_INSTALL_DIR}/lib/vmware/bin/dictTool \
		${VM_INSTALL_DIR}/lib/vmware/bin/emmett \
		${VM_INSTALL_DIR}/lib/vmware/bin/fusermount \
		${VM_INSTALL_DIR}/lib/vmware/bin/mkisofs \
		${VM_INSTALL_DIR}/lib/vmware/bin/mksSandbox \
		${VM_INSTALL_DIR}/lib/vmware/bin/mksSandbox-debug \
		${VM_INSTALL_DIR}/lib/vmware/bin/mksSandbox-stats \
		${VM_INSTALL_DIR}/lib/vmware/bin/tpm2emu \
		${VM_INSTALL_DIR}/lib/vmware/bin/tpm2emu-v159 \
		${VM_INSTALL_DIR}/lib/vmware/bin/vmcli \
		${VM_INSTALL_DIR}/lib/vmware/bin/vmrest \
		${VM_INSTALL_DIR}/lib/vmware/bin/vmrun \
		${VM_INSTALL_DIR}/lib/vmware/bin/vmware-remotemks \
		${VM_INSTALL_DIR}/lib/vmware/bin/vmware-usbarbitrator

	_vmware_fperms_ifexists 0755 \
		${VM_INSTALL_DIR}/lib/vmware/setup/vmware-config \
		${VM_INSTALL_DIR}/lib/vmware/lib/libvmware-gksu.so/gksu-run-helper \
		${VM_INSTALL_DIR}/lib/vmware/lib/libvmware-vprobe.so/libvmware-vprobe.so \
		${VM_INSTALL_DIR}/lib/vmware/scripts/init/vmware \
		${VM_INSTALL_DIR}/lib/vmware/scripts/init/vmware-USBArbitrator

	# Match the working vendor/Gentoo runtime for non-root guest startup.
	_vmware_fperms_ifexists 4755 \
		${VM_INSTALL_DIR}/sbin/vmware-authd \
		${VM_INSTALL_DIR}/lib/vmware/bin/vmware-vmx \
		${VM_INSTALL_DIR}/lib/vmware/bin/vmware-vmx-debug \
		${VM_INSTALL_DIR}/lib/vmware/bin/vmware-vmx-stats

	use vix && _vmware_fperms_ifexists 0755 \
		${VM_INSTALL_DIR}/lib/vmware-vix/setup/vmware-config

	# Environment.
	cat > "${T}/90vmware" <<-EOF || die
		CONFIG_PROTECT_MASK="/etc/vmware-installer"
	EOF
	doenvd "${T}/90vmware"

	insinto /etc/revdep-rebuild
	echo "SEARCH_DIRS_MASK=\"${VM_INSTALL_DIR}\"" > "${T}/10vmware-workstation" || die
	doins "${T}/10vmware-workstation"

	# Configuration.
	dodir /etc/vmware

	cat > "${ED}/etc/vmware/bootstrap" <<-EOF || die
		BINDIR='${VM_INSTALL_DIR}/bin'
		LIBDIR='${VM_INSTALL_DIR}/lib'
	EOF

	cat > "${ED}/etc/vmware/config" <<-EOF || die
		.encoding = "UTF-8"
		bindir = "${VM_INSTALL_DIR}/bin"
		libdir = "${VM_INSTALL_DIR}/lib/vmware"
		initscriptdir = "/etc/init.d"
		authd.fullpath = "${VM_INSTALL_DIR}/sbin/vmware-authd"
		gksu.rootMethod = "su"
		VMCI_CONFED = "no"
		VMBLOCK_CONFED = "no"
		VSOCK_CONFED = "no"
		NETWORKING = "yes"
		player.product.version = "${MY_RELEASE}"
		product.buildNumber = "${PV_BUILD}"
		product.version = "${MY_RELEASE}"
		product.name = "VMware Workstation"
		workstation.product.version = "${MY_RELEASE}"
		vmware.fullpath = "${VM_INSTALL_DIR}/bin/vmware"
		installerDefaults.componentDownloadEnabled = "no"
		installerDefaults.autoSoftwareUpdateEnabled.epoch = "4641104763"
		installerDefaults.dataCollectionEnabled.epoch = "7910652514"
		installerDefaults.dataCollectionEnabled = "no"
		installerDefaults.transferVersion = "1"
		installerDefaults.autoSoftwareUpdateEnabled = "no"
		acceptEULA = "yes"
		acceptOVFEULA = "yes"
	EOF

	if use vix; then
		cat >> "${ED}/etc/vmware/config" <<-EOF || die
			vix.libdir = "${VM_INSTALL_DIR}/lib/vmware-vix"
			vix.config.version = "1"
		EOF
	fi

	if use systemd; then
		local sd="${WORKDIR}/vmware-systemd-${SYSTEMD_COMMIT}"
		systemd_dounit \
			"${sd}/vmware-authentication.service" \
			"${sd}/vmware-usb.service" \
			"${sd}/vmware-vmci.service" \
			"${sd}/vmware-vmmon.service" \
			"${sd}/vmware-vmnet.service" \
			"${sd}/vmware-vmsock.service" \
			"${sd}/vmware.target"
	fi

	if use macos-guests; then
		python "${WORKDIR}/unlocker-${UNLOCKER_VERSION}/unlocker.py" \
			>/dev/null || die "unlocker.py failed"
	fi

	local guest_flag guest_dir dbfile
	for guest_flag in darwin linux linuxpreglibc25 netware solaris windows winpre2k winprevista; do
		use vmware_guests_${guest_flag} || continue

		guest_dir=$(_vmware_guest_dirname "${guest_flag}")
		dbfile="${ED}/etc/vmware-installer/database"

		if [[ ! -e ${dbfile} ]]; then
			touch "${dbfile}" || die
			sqlite3 "${dbfile}" \
				"CREATE TABLE settings(key VARCHAR PRIMARY KEY, value VARCHAR NOT NULL, component_name VARCHAR NOT NULL);" || die
			sqlite3 "${dbfile}" \
				"INSERT INTO settings(key,value,component_name) VALUES('db.schemaVersion','2','vmware-installer');" || die
			sqlite3 "${dbfile}" \
				"CREATE TABLE components(id INTEGER PRIMARY KEY, name VARCHAR NOT NULL, version VARCHAR NOT NULL, buildNumber INTEGER NOT NULL, component_core_id INTEGER NOT NULL, longName VARCHAR NOT NULL, description VARCHAR, type INTEGER NOT NULL);" || die
		fi

		local manifest="vmware-tools-${guest_dir}/manifest.xml"
		local cols="name,version,buildNumber,component_core_id,longName,description,type"
		local values
		if [[ -e ${manifest} ]]; then
			local version
			version="$(grep -oPm1 '(?<=<version>)[^<]+' "${manifest}")" || die
			values="'vmware-tools-${guest_dir}','${version}','${PV_BUILD}',1,'${guest_dir}','${guest_dir}',1"
			sqlite3 "${dbfile}" \
				"INSERT INTO components(${cols}) VALUES(${values});" || die
		elif [[ ${guest_flag} == darwin ]]; then
			values="'vmware-tools-darwin','${VMWARE_FUSION_VER%/*}','${VMWARE_FUSION_VER#*/}',1,'darwin','darwin',1"
			sqlite3 "${dbfile}" \
				"INSERT INTO components(${cols}) VALUES(${values});" || die
		fi

		if [[ -e vmware-tools-${guest_dir}/${guest_dir}.iso ]]; then
			insinto "${VM_INSTALL_DIR}/lib/vmware/isoimages"
			doins "vmware-tools-${guest_dir}/${guest_dir}.iso"
		fi
	done

	readme.gentoo_create_doc
}

pkg_config() {
	"${VM_INSTALL_DIR}/bin/vmware-networks" \
		--postinstall vmware-workstation,old,new \
		|| die "vmware-networks --postinstall failed"
}

pkg_postinst() {
	xdg_pkg_postinst
	readme.gentoo_print_elog
}

pkg_postrm() {
	xdg_pkg_postrm
}
