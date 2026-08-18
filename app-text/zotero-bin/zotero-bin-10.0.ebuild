# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop xdg

DESCRIPTION="Helps you collect, organize, cite, and share your research sources"
HOMEPAGE="https://www.zotero.org"
BASE_URI="https://www.zotero.org/download/client/dl?channel=release&platform"
SRC_URI="
	amd64? ( ${BASE_URI}=linux-x86_64&version=${PV} -> ${P}-amd64.tar.xz )
	arm64? ( ${BASE_URI}=linux-arm64&version=${PV} -> ${P}-arm64.tar.xz )
	x86? ( ${BASE_URI}=linux-i686&version=${PV} -> ${P}-x86.tar.xz )
"
S="${WORKDIR}"

LICENSE="AGPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"

# Forked from Gentoo's own app-text/zotero-bin (9.0.6) and bumped to the
# next real release. Note: upstream's git tag for this release is 10.0.0,
# but the actually-published download version string (and the only one
# that resolves on download.zotero.org) is 10.0 -- the 10.0.0 tag has no
# live artifact (S3 AccessDenied on every platform). Verified all three
# platform downloads resolve to real files before trusting this PV.
#
# RDEPEND re-derived from a full `scanelf -qn -R` across the whole bundle
# (not just zotero-bin itself -- most of the real dependency surface is
# in the bundled libxul.so) plus a grep for dlopen'd sonames inside it.
# dev-libs/dbus-glib dropped: zero references anywhere in the bundle --
# Gecko's D-Bus integration (MPRIS media-key interface, app launcher) now
# goes through a bundled Rust `dbus` crate linking libdbus-1 directly,
# confirmed via strings in libxul.so referencing
# third_party/rust/dbus/src/{lib,message,strings}.rs. x11-libs/libXtst and
# app-accessibility/at-spi2-core are kept: both are absent from the ELF
# NEEDED set but genuinely dlopen'd (confirmed via string matches for
# "Xtst"/"atk-bridge" inside libxul.so).
RDEPEND="
	app-accessibility/at-spi2-core
	dev-libs/glib
	dev-libs/nspr
	dev-libs/nss
	media-libs/alsa-lib
	media-libs/fontconfig
	media-libs/freetype
	sys-apps/dbus
	sys-libs/glibc
	x11-libs/cairo
	x11-libs/gtk+:3
	x11-libs/libX11
	x11-libs/libxcb
	x11-libs/libXcomposite
	x11-libs/libXcursor
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXi
	x11-libs/libXrandr
	x11-libs/libXrender
	x11-libs/libXtst
	x11-libs/pango
"

QA_PREBUILT="opt/zotero/*"

src_prepare() {
	if use amd64; then
		cd Zotero_linux-x86_64 || die
	elif use arm64; then
		cd Zotero_linux-arm64 || die
	elif use x86; then
		cd Zotero_linux-i686 || die
	fi

	# disable auto-update
	sed -i -e 's#URL=.*#URL=#' app/application.ini || die

	# fix desktop-file
	sed -i -e 's#^Exec=.*#Exec=zotero -url %U#' zotero.desktop || die
	sed -i -e 's#Icon=zotero.*#Icon=zotero#' zotero.desktop || die

	default
}

src_install() {
	if use amd64; then
		cd Zotero_linux-x86_64 || die
	elif use x86; then
		cd Zotero_linux-i686 || die
	fi

	dodir opt/zotero
	cp -a * "${ED}/opt/zotero" || die

	dosym ../../opt/zotero/zotero usr/bin/zotero

	domenu zotero.desktop

	for size in 32 64 128; do
		newicon -s ${size} icons/icon${size}.png zotero.png
	done
}
