# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop unpacker xdg

DESCRIPTION="Desktop application for Claude.ai (Chat, Cowork, and Claude Code)"
HOMEPAGE="https://claude.ai https://code.claude.com/docs/en/desktop-linux"

# Anthropic publishes the app as .deb packages in an apt repository. There
# is no source release; we repackage the prebuilt Electron bundle. The pool
# path is stable; the per-arch filename encodes ${PV}.
BASE_URI="https://downloads.claude.ai/claude-desktop/apt/stable/pool/main/c/${PN}"
SRC_URI="
	amd64? ( ${BASE_URI}/${PN}_${PV}_amd64.deb )
	arm64? ( ${BASE_URI}/${PN}_${PV}_arm64.deb )
"
S="${WORKDIR}"

LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# Proprietary prebuilt Electron bundle: not redistributable, must not be
# stripped or byte-modified.
RESTRICT="bindist mirror strip"

QA_PREBUILT="opt/${PN}/*"

# Runtime libraries the bundle links against (derived from the ELF NEEDED
# entries of the shipped binaries) plus the helpers it dlopen()s at runtime
# (libsecret for the keyring, libnotify) and the desktop-integration tools
# the app shells out to. libcap-ng and libseccomp are pulled in by the
# bundled `resources/virtiofsd` VM filesystem helper. Re-scanned on the
# 1.32352.1 bump (scanelf -qn across every ELF/.node file in the bundle,
# not just the main binary): x11-libs/libXtst and sys-apps/util-linux
# (libuuid1) dropped — neither soname appears anywhere in the bundle any
# more. Global shortcuts now go through org.freedesktop.portal.GlobalShortcuts
# (confirmed via a literal string match in the main binary), already covered
# by sys-apps/xdg-desktop-portal; Chromium's own base::Uuid replaced the
# external libuuid dependency some releases back.
RDEPEND="
	app-accessibility/at-spi2-core
	app-crypt/libsecret
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/nss
	media-libs/alsa-lib
	media-libs/mesa
	net-print/cups
	sys-apps/dbus
	sys-apps/xdg-desktop-portal
	sys-libs/libcap-ng
	sys-libs/libseccomp
	virtual/libudev
	x11-libs/cairo
	x11-libs/gtk+:3
	x11-libs/libX11
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXrandr
	x11-libs/libdrm
	x11-libs/libnotify
	x11-libs/libxcb
	x11-libs/libxkbcommon
	x11-libs/pango
	x11-misc/xdg-utils
"

src_install() {
	# Relocate the self-contained Electron bundle under /opt (Gentoo policy
	# for prebuilt proprietary blobs). Electron resolves its payload relative
	# to the executable, so the whole tree just moves together. cp -a keeps
	# the upstream permission bits (executable helpers, .so files).
	local dir="/opt/${PN}"
	dodir "${dir}"
	cp -a usr/lib/claude-desktop/. "${ED}${dir}/" || die "failed to install bundle"

	# chrome-sandbox needs to be setuid root so Chromium's SUID sandbox works
	# where unprivileged user namespaces are unavailable; with userns it is
	# harmless. Matches Chrome / other Electron ebuilds.
	fperms 4755 "${dir}/chrome-sandbox"

	dosym "${dir}/claude-desktop" /usr/bin/${PN}

	# Upstream ships the desktop file under a reverse-DNS name rather than
	# ${PN}; the icon/doc paths still use ${PN}.
	domenu usr/share/applications/com.anthropic.Claude.desktop

	local size
	for size in 16 32 48 128 256; do
		doicon -s ${size} \
			"usr/share/icons/hicolor/${size}x${size}/apps/${PN}.png"
	done

	dodoc usr/share/doc/claude-desktop/copyright
}
