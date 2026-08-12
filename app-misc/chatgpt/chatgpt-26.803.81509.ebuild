# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop unpacker xdg

DESCRIPTION="Desktop application for ChatGPT (Chat, Work, and Codex)"
HOMEPAGE="https://chatgpt.com https://developers.openai.com/codex/app"

# OpenAI publishes the app as .deb/.rpm packages, but unlike Anthropic's apt
# pool the filename is not version-qualified -- only a "latest" pointer
# exists (confirmed: no .../deb/${PV}/... or .../deb/v${PV}/... path works).
# There is no source release; we repackage the prebuilt Electron bundle.
# The "-> ${P}_arch.deb" rename pins the distfile to this PV so old Manifest
# entries stay distinguishable in DISTDIR; it does NOT make old versions
# re-fetchable -- once upstream moves "latest" forward, only the newest
# ebuild's hash will still match, exactly as if the tarball were replaced
# in place. Re-run `pkgdev manifest` on every bump.
BASE_URI="https://persistent.oaistatic.com/codex-app-prod/linux/deb/latest"
SRC_URI="
	amd64? ( ${BASE_URI}/chatgpt_amd64.deb -> ${P}_amd64.deb )
	arm64? ( ${BASE_URI}/chatgpt_arm64.deb -> ${P}_arm64.deb )
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
# entries of the main Electron binary, the crashpad handler, the bundled
# Node.js runtime used for Codex's "computer use" tooling, and its native
# addons) plus libraries upstream's own apt Depends: field lists that no
# scanned binary directly NEEDS -- almost certainly dlopen()d rather than
# link-time (libnotify for desktop notifications; dev-libs/openssl and
# dev-libs/libusb are not referenced by any ELF NEEDED we found either,
# but both are hard Depends: upstream and libusb lines up with the
# bundled node-hid/serialport native modules used for device support).
# dev-vcs/git is upstream's own Recommends: -- Codex's "run in your local
# repos" feature shells out to it.
#
# The bundle also ships optional Qt5/Qt6 "shim" libraries
# (libqt5_shim.so, libqt6_shim.so) for native dialog/theming integration
# on Qt-based desktops. Neither Qt5 nor Qt6 itself is bundled, and neither
# appears in upstream's Depends:, so they are an optional dlopen and are
# not added to RDEPEND.
#
# Unlike claude-desktop, this bundle ships no chrome-sandbox setuid
# helper at all (confirmed absent from the .deb payload), so there is no
# fperms 4755 step here.
RDEPEND="
	app-accessibility/at-spi2-core
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/libusb
	dev-libs/nspr
	dev-libs/nss
	dev-libs/openssl:0
	dev-vcs/git
	media-gfx/graphite2
	media-libs/alsa-lib
	media-libs/mesa
	net-print/cups
	sys-apps/dbus
	virtual/libudev
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
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
	cp -a usr/lib/chatgpt/. "${ED}${dir}/" || die "failed to install bundle"

	# codex-launcher is upstream's own thin entry-point wrapper (resolves
	# its own directory and execs the ChatGPT binary alongside it); keep
	# using it rather than symlinking straight to ChatGPT so we pick up
	# any logic upstream adds there later for free.
	dosym "${dir}/codex-launcher" /usr/bin/${PN}

	domenu usr/share/applications/${PN}.desktop

	# Upstream ships a single 1024x1024 pixmap, not a sized hicolor set.
	doicon usr/share/pixmaps/${PN}.png

	dodoc usr/share/doc/${PN}/copyright
}
