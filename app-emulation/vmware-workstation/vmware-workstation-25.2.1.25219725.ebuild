# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{13..14} )

inherit desktop edo pam python-any-r1 readme.gentoo-r1 systemd xdg

# Version layout: 25.2.1.25219725 → 25H2u1 build 25219725
MY_YEAR=$(ver_cut 1)
MY_HALF=$(ver_cut 2)
MY_UPDATE=$(ver_cut 3)
PV_BUILD=$(ver_cut 4)

MY_RELEASE="${MY_YEAR}H${MY_HALF}"
[[ ${MY_UPDATE} -gt 0 ]] && MY_RELEASE+="u${MY_UPDATE}"

MY_PN="VMware-Workstation-Full"
MY_P="${MY_PN}-${MY_RELEASE}-${PV_BUILD}"
PV_MODULES="$(ver_cut 1-2)"

VMWARE_FUSION_VER="13.6.3/24585314"
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
REQUIRED_USE="vmware_guests_darwin? ( macos-guests )"

RESTRICT="fetch mirror preserve-libs strip"

# Guest tools via USE_EXPAND — set VMWARE_GUESTS="windows darwin" in make.conf
IUSE+="
	$(printf 'vmware_guests_%s ' \
		darwin linux linuxpreglibc25 netware solaris windows winpre2k winprevista)
"

RDEPEND="
	app-arch/unzip
	dev-db/sqlite:3
	dev-libs/dbus-glib
	dev-libs/gmp:0
	dev-libs/icu:=
	dev-libs/json-c:=
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
	ovftool? ( !dev-util/ovftool )
"
DEPEND="${PYTHON_DEPS}"
BDEPEND="
	app-admin/chrpath
	app-arch/unzip
"

QA_TEXTRELS="opt/vmware/lib/vmware/bin/vmware-vmx*"

# Map lowercase USE_EXPAND values to VMware's directory names
_vmware_guest_dirname() {
	case ${1} in
		linuxpreglibc25) echo "linuxPreGlibc25" ;;
		winpre2k)        echo "winPre2k" ;;
		winprevista)     echo "winPreVista" ;;
		*)               echo "${1}" ;;
	esac
}

pkg_nofetch() {
	einfo "Please download ${MY_P}.x86_64.bundle from"
	einfo "  ${HOMEPAGE}"
	einfo "and place it in your DISTDIR directory."
}

src_unpack() {
	for a in ${A}; do
		if [[ ${a} == *.bundle ]]; then
			edo cp "${DISTDIR}/${a}" "${WORKDIR}"
		else
			unpack "${a}"
		fi
	done

	# LC_ALL=C avoids locale-related extraction failures
	export LC_ALL=C
	edo sh "${WORKDIR}/${MY_P}.x86_64.bundle" \
		--console --required --eulas-agreed -x extracted

	if ! use vix; then
		edo rm -r extracted/vmware-vix-core extracted/vmware-vix-lib-Workstation*
	fi

	# Stage darwin.iso for guest tools installation
	if use vmware_guests_darwin; then
		edo mkdir -p extracted/vmware-tools-darwin
		edo cp "${DISTDIR}/darwin.iso" extracted/vmware-tools-darwin/
	fi

	# Remove bundled libstdc++ — use system version
	rm -rf extracted/vmware-vmx/lib/lib/libstdc++.so.6 || true
}

src_prepare() {
	default

	# Bug 459566 — libvmware-netcfg.so path fix
	edo mkdir vmware-network-editor/lib/lib
	edo mv vmware-network-editor/lib/libvmware-netcfg.so \
		vmware-network-editor/lib/lib/

	# Remove VMware's own module compiler — we use vmware-modules
	rm -f */bin/vmware-modconfig || true
	rm -rf */lib/modules/binary || true

	# Remove configure-initscript.sh — we manage services ourselves
	edo rm -f vmware-installer/bin/configure-initscript.sh

	# Fix rpath in ovftool's bundled libcurl
	edo chrpath -d vmware-ovftool/libcurl.so.4

	# Prepare macOS unlocker
	if use macos-guests; then
		sed -i \
			-e "s#vmx_path = '/usr#vmx_path = '${ED}${VM_INSTALL_DIR}#" \
			-e "s#os.path.isfile('/usr#os.path.isfile('${ED}${VM_INSTALL_DIR}#" \
			-e "s#vmwarebase = '/usr#vmwarebase = '${ED}${VM_INSTALL_DIR}#" \
			"${WORKDIR}"/unlocker-"${UNLOCKER_VERSION}"/unlocker.py || die
	fi

	DOC_CONTENTS="
/etc/env.d is updated during ${PN} installation. Please run:\\n
'env-update && source /etc/profile'\\n
Before you can use ${PN}, you must configure a default network setup.
You can do this by running 'emerge --config ${PN}'.\\n
To be able to run ${PN} your user must be in the vmware group.\\n"
}

src_install() {
	local vmware_installer_version
	vmware_installer_version=$(grep -oPm1 "(?<=<version>)[^<]+" \
		vmware-installer/manifest.xml)

	#
	# --- Binaries ---
	#

	into ${VM_INSTALL_DIR}

	dobin \
		vmware-vmx/bin/vmnet-{bridge,dhcpd,natd,netifup,sniffer} \
		vmware-vmx/bin/vmware-{collect-host-support-info,gksu,networks,ping} \
		vmware-workstation/bin/{vmss2core,vmware,vmware-tray,vmware-vdiskmanager} \
		vmware-vprobe/bin/vmware-vprobe \
		vmware-player-app/bin/vmware-license-{check,enter}.sh \
		vmware-usbarbitrator/bin/vmware-usbarbitrator

	dosbin vmware-vmx/sbin/{vmware-authd,vmware-authdlauncher}

	#
	# --- Libraries ---
	#

	insinto ${VM_INSTALL_DIR}/lib/vmware
	doins -r \
		vmware-network-editor/lib/. \
		vmware-player-app/lib/. \
		vmware-vmx/lib/. \
		vmware-vprobe/lib/. \
		vmware-workstation/lib/. \
		vmware-vmx/roms

	# Remove unnecessary bundled libraries
	edo rm -rf \
		"${ED}"${VM_INSTALL_DIR}/lib/vmware/lib{nfc-types,soclient,vim-types}.so \
		"${ED}"${VM_INSTALL_DIR}/lib/vmware/libvm{acore,omi,ware-hostd,ware-wssc-adminTool}.so \
		"${ED}"${VM_INSTALL_DIR}/lib/vmware/diskLibWrapper.so \
		"${ED}"${VM_INSTALL_DIR}/lib/vmware/lib/libstdc++.so.6

	#
	# --- VMware Installer infrastructure ---
	#

	insinto ${VM_INSTALL_DIR}/lib/vmware-installer/"${vmware_installer_version}"
	doins -r vmware-installer/{cdsHelper,vmis,vmis-launcher,vmware-cds-helper,vmware-installer,vmware-installer.py,python}
	# sopython may exist in newer bundles
	[[ -d vmware-installer/sopython ]] && doins -r vmware-installer/sopython

	chrpath -k -r '/../lib:$ORIGIN/../lib' \
		"${ED}"${VM_INSTALL_DIR}/lib/vmware-installer/"${vmware_installer_version}"/python/lib/lib-dynload/*.so \
		>/dev/null || die "chrpath for lib-dynload failed"

	fperms 0755 ${VM_INSTALL_DIR}/lib/vmware-installer/"${vmware_installer_version}"/{vmis-launcher,cdsHelper,vmware-installer}
	dosym ../lib/vmware-installer/"${vmware_installer_version}"/vmware-installer \
		${VM_INSTALL_DIR}/bin/vmware-installer

	rm -f \
		"${ED}${VM_INSTALL_DIR}/lib/vmware-installer/${vmware_installer_version}/python/lib/lib-dynload/_bz2.cpython-310-x86_64-linux-gnu.so" \
		"${ED}${VM_INSTALL_DIR}/lib/vmware-installer/${vmware_installer_version}/python/lib/lib-dynload/_gdbm.cpython-310-x86_64-linux-gnu.so" \
		"${ED}${VM_INSTALL_DIR}/lib/vmware-installer/${vmware_installer_version}/python/lib/lib-dynload/"*_failed.so || die

	insinto /etc/vmware-installer
	doins vmware-installer/bootstrap
	sed -i \
		-e "s/@@VERSION@@/${vmware_installer_version}/" \
		-e "s,@@VMWARE_INSTALLER@@,${VM_INSTALL_DIR}/lib/vmware-installer/${vmware_installer_version}," \
		"${ED}"/etc/vmware-installer/bootstrap || die

	#
	# --- Desktop integration ---
	#

	# Workstation
	insinto /usr/share/metainfo
	doins vmware-workstation/share/appdata/vmware-workstation.appdata.xml
	domenu vmware-workstation/share/applications/vmware-workstation.desktop
	local size
	for size in 16 22 24 32 48 256; do
		doicon -s "${size}" \
			vmware-workstation/share/icons/hicolor/"${size}x${size}"/apps/vmware-workstation.png
	done
	dosym ../icons/hicolor/256x256/apps/vmware-workstation.png \
		/usr/share/pixmaps/vmware-workstation.png

	# Player
	insinto /usr/share/metainfo
	doins vmware-player-app/share/appdata/vmware-player.appdata.xml
	domenu vmware-player-app/share/applications/vmware-player.desktop
	for size in 16 22 24 32 48 256; do
		doicon -s "${size}" \
			vmware-player-app/share/icons/hicolor/"${size}x${size}"/apps/vmware-player.png
	done
	dosym ../icons/hicolor/256x256/apps/vmware-player.png \
		/usr/share/pixmaps/vmware-player.png

	# MIME types
	insinto /usr/share/mime/packages
	doins vmware-player-app/share/mime/packages/vmware-player.xml

	# Network editor
	domenu vmware-network-editor-ui/share/applications/vmware-netcfg.desktop
	for size in 16 22 24 32 48 256; do
		doicon -s "${size}" \
			vmware-network-editor-ui/share/icons/hicolor/"${size}x${size}"/apps/vmware-netcfg.png
	done
	dosym ../icons/hicolor/256x256/apps/vmware-netcfg.png \
		/usr/share/pixmaps/vmware-netcfg.png

	# Fix desktop file placeholders
	sed -i \
		-e "s:@@LIBCONF_DIR@@:${EPREFIX}${VM_INSTALL_DIR}/lib/vmware/libconf:g" \
		"${ED}"${VM_INSTALL_DIR}/lib/vmware/libconf/etc/gtk-3.0/gdk-pixbuf.loaders || die
	sed -i \
		-e "s:@@BINARY@@:${EPREFIX}${VM_INSTALL_DIR}/bin/vmplayer:g" \
		-e "/^Encoding/d" \
		"${ED}"/usr/share/applications/vmware-player.desktop || die
	sed -i \
		-e "s:@@BINARY@@:${EPREFIX}${VM_INSTALL_DIR}/bin/vmware:g" \
		-e "/^Encoding/d" \
		"${ED}"/usr/share/applications/vmware-workstation.desktop || die
	sed -i \
		-e "s:@@BINARY@@:${EPREFIX}${VM_INSTALL_DIR}/bin/vmware-netcfg:g" \
		-e "/^Encoding/d" \
		"${ED}"/usr/share/applications/vmware-netcfg.desktop || die

	#
	# --- Setup script ---
	#

	exeinto ${VM_INSTALL_DIR}/lib/vmware/setup
	doexe vmware-player-setup/vmware-config

	#
	# --- Documentation ---
	#

	docompress -x /usr/share/doc/${PF}
	dodoc vmware-workstation/doc/EULA

	# OVFTool EULA is always needed
	insinto /usr/lib/vmware-ovftool
	doins vmware-ovftool/vmware.eula

	if use doc; then
		dodoc -r */doc/*
	fi

	#
	# --- PAM ---
	#

	pamd_mimic_system vmware-authd auth account

	#
	# --- FUSE configuration ---
	#

	insinto /etc/modprobe.d
	newins vmware-vmx/etc/modprobe.d/modprobe-vmware-fuse.conf vmware-fuse.conf

	#
	# --- VIX ---
	#

	if use vix; then
		into ${VM_INSTALL_DIR}
		dobin vmware-vix-core/bin/vmrun

		insinto ${VM_INSTALL_DIR}/lib/vmware-vix
		doins -r vmware-vix-core/lib/.
		doins -r vmware-vix-lib-Workstation"$(ver_cut 1)"00/lib/.
		dosym vmware-vix/libvixAllProducts.so ${VM_INSTALL_DIR}/lib/libbvixAllProducts.so

		insinto /usr/include/vmware-vix
		doins vmware-vix-core/include/{vix,vm_basic_types}.h
	fi

	#
	# --- OVFTool ---
	#

	if use ovftool; then
		insinto ${VM_INSTALL_DIR}/lib/vmware-ovftool
		doins -r "${S}"/vmware-ovftool/.

		chmod 0755 "${ED}"${VM_INSTALL_DIR}/lib/vmware-ovftool/{ovftool,ovftool.bin} || die
		sed -i 's/readlink/readlink -f/' \
			"${ED}"${VM_INSTALL_DIR}/lib/vmware-ovftool/ovftool || die
		dosym ../lib/vmware-ovftool/ovftool ${VM_INSTALL_DIR}/bin/ovftool
	fi

	#
	# --- Tool symlinks ---
	#

	local tool
	for tool in thnuclnt vmware vmplayer{,-daemon} licenseTool vmamqpd \
			vmware-{app-control,enter-serial,gksu,fuseUI,modconfig{,-console},netcfg,{setup,unity}-helper,tray,vmblock-fuse,vprobe,zenity}; do
		dosym appLoader ${VM_INSTALL_DIR}/lib/vmware/bin/"${tool}"
	done
	dosym ../lib/vmware/bin/vmplayer ${VM_INSTALL_DIR}/bin/vmplayer
	dosym ../lib/vmware/bin/vmware ${VM_INSTALL_DIR}/bin/vmware
	dosym ../lib/vmware/bin/vmware-fuseUI ${VM_INSTALL_DIR}/bin/vmware-fuseUI
	dosym ../lib/vmware/bin/vmware-netcfg ${VM_INSTALL_DIR}/bin/vmware-netcfg
	dosym ../../${VM_INSTALL_DIR}/lib/vmware/icu /etc/vmware/icu

	#
	# --- Permissions ---
	#

	fperms 0755 ${VM_INSTALL_DIR}/lib/vmware/bin/{appLoader,fusermount,mkisofs,vmware-remotemks}
	fperms 0755 ${VM_INSTALL_DIR}/lib/vmware/bin/mksSandbox{,-debug,-stats}
	fperms 0755 ${VM_INSTALL_DIR}/lib/vmware/bin/{emmett,tpm2emu,vmrest}
	fperms 0755 ${VM_INSTALL_DIR}/lib/vmware/setup/vmware-config
	fperms 4711 ${VM_INSTALL_DIR}/lib/vmware/bin/vmware-vmx{,-debug,-stats}
	fperms 0755 ${VM_INSTALL_DIR}/lib/vmware/lib/libvmware-gksu.so/gksu-run-helper
	fperms 4711 ${VM_INSTALL_DIR}/sbin/vmware-authd
	use vix && fperms 0755 ${VM_INSTALL_DIR}/lib/vmware-vix/setup/vmware-config

	#
	# --- Environment ---
	#

	cat > "${T}"/90vmware <<-EOF || die
		PATH="${VM_INSTALL_DIR}/bin"
		ROOTPATH="${VM_INSTALL_DIR}/bin"
		CONFIG_PROTECT_MASK="/etc/vmware-installer"
		VMWARE_USE_SHIPPED_LIBS=1
	EOF
	doenvd "${T}"/90vmware

	# Mask for revdep-rebuild — VMware ships its own library ecosystem
	insinto /etc/revdep-rebuild
	echo "SEARCH_DIRS_MASK=\"${VM_INSTALL_DIR}\"" > "${T}"/10vmware-workstation
	doins "${T}"/10vmware-workstation

	#
	# --- Configuration ---
	#

	dodir /etc/vmware

	cat > "${ED}"/etc/vmware/bootstrap <<-EOF || die
		BINDIR='${VM_INSTALL_DIR}/bin'
		LIBDIR='${VM_INSTALL_DIR}/lib'
	EOF

	cat > "${ED}"/etc/vmware/config <<-EOF || die
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
		cat >> "${ED}"/etc/vmware/config <<-EOF || die
			vix.libdir = "${VM_INSTALL_DIR}/lib/vmware-vix"
			vix.config.version = "1"
		EOF
	fi

	#
	# --- Systemd ---
	#

	if use systemd; then
		local sd="${WORKDIR}/vmware-systemd-${SYSTEMD_COMMIT}"
		systemd_dounit \
			"${sd}"/vmware-{authentication,usb,vmblock,vmci,vmmon,vmnet,vmsock}.service \
			"${sd}"/vmware.target
	fi

	#
	# --- macOS guest support ---
	#

	if use macos-guests; then
		python "${WORKDIR}"/unlocker-"${UNLOCKER_VERSION}"/unlocker.py \
			>/dev/null || die "unlocker.py failed"
	fi

	#
	# --- Guest tools ---
	#

	local guest_flag guest_dir dbfile
	for guest_flag in darwin linux linuxpreglibc25 netware solaris windows winpre2k winprevista; do
		use vmware_guests_${guest_flag} || continue

		guest_dir=$(_vmware_guest_dirname "${guest_flag}")

		# Initialize the installer database on first guest
		dbfile="${ED}"/etc/vmware-installer/database
		if [[ ! -e "${dbfile}" ]]; then
			touch "${dbfile}" || die
			sqlite3 "${dbfile}" \
				"CREATE TABLE settings(key VARCHAR PRIMARY KEY, value VARCHAR NOT NULL, component_name VARCHAR NOT NULL);" \
				|| die
			sqlite3 "${dbfile}" \
				"INSERT INTO settings(key,value,component_name) VALUES('db.schemaVersion','2','vmware-installer');" \
				|| die
			sqlite3 "${dbfile}" \
				"CREATE TABLE components(id INTEGER PRIMARY KEY, name VARCHAR NOT NULL, version VARCHAR NOT NULL, buildNumber INTEGER NOT NULL, component_core_id INTEGER NOT NULL, longName VARCHAR NOT NULL, description VARCHAR, type INTEGER NOT NULL);" \
				|| die
		fi

		# Register the component
		local manifest="vmware-tools-${guest_dir}/manifest.xml"
		if [[ -e "${manifest}" ]]; then
			local version
			version="$(grep -oPm1 '(?<=<version>)[^<]+' "${manifest}")"
			sqlite3 "${dbfile}" \
				"INSERT INTO components(name,version,buildNumber,component_core_id,longName,description,type) \
				VALUES('vmware-tools-${guest_dir}','${version}','${PV_BUILD}',1,'${guest_dir}','${guest_dir}',1);" \
				|| die
		elif [[ ${guest_flag} == darwin ]]; then
			sqlite3 "${dbfile}" \
				"INSERT INTO components(name,version,buildNumber,component_core_id,longName,description,type) \
				VALUES('vmware-tools-darwin','${VMWARE_FUSION_VER%/*}','${VMWARE_FUSION_VER#*/}',1,'darwin','darwin',1);" \
				|| die
		fi

		# Install the ISO if present
		if [[ -e "vmware-tools-${guest_dir}/${guest_dir}.iso" ]]; then
			insinto ${VM_INSTALL_DIR}/lib/vmware/isoimages
			doins "vmware-tools-${guest_dir}/${guest_dir}.iso"
		fi
	done

	readme.gentoo_create_doc
}

pkg_config() {
	"${VM_INSTALL_DIR}"/bin/vmware-networks \
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
