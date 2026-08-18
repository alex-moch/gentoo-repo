# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop pax-utils unpacker xdg

DESCRIPTION="Discover, download, and run LLMs locally"
HOMEPAGE="https://lmstudio.ai"

# LM Studio has no releases feed (closed source) and no machine-readable
# version endpoint; the current version+build pair has to be scraped from
# the embedded JSON on https://lmstudio.ai/download (look for
# "linux":{"x64":{"version":...,"build":...}}). The download URL and the
# .deb's own internal Version: field (0.4.21+2) both encode the build
# number separately from the marketing version -- track it here rather
# than folding it into PV, since respins reuse the same PV with a bumped
# BUILD (bump this and regenerate the Manifest; no ebuild rename needed).
BUILD=2
MY_PV="${PV}-${BUILD}"

# Only amd64 ships a .deb; arm64 is AppImage-only (no .deb at all, verified
# against the same download-page JSON -- "arm64":{"debSha512":null}), so
# this ebuild is amd64-only until an AppImage-based src_unpack is written.
SRC_URI="amd64? ( https://installers.lmstudio.ai/linux/x64/${MY_PV}/LM-Studio-${MY_PV}-x64.deb -> ${P}.deb )"
S="${WORKDIR}"

LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="~amd64"
IUSE="cuda vulkan"

# Proprietary Electron bundle: not redistributable, must not be stripped
# (breaks the prebuilt llama.cpp backends and the bundled `lms`/Electron
# binaries the same way it does for app-misc/claude-desktop).
RESTRICT="bindist mirror strip"

# ~2.2GB unpacked. Most of that is optional llama.cpp inference backends
# bundled under resources/app/.webpack/bin/extensions/backends: a CPU
# (avx2) backend always ships, plus optional CUDA (~600MB combined
# backend + vendored cuBLAS/cuDART libs) and Vulkan (~21MB) backends.
# There is no ROCm backend in this build despite some other overlays'
# ebuilds declaring IUSE=rocm for it -- checked the actual archive
# contents, only avx2/nvidia-cuda-avx2/vulkan-avx2 backend dirs exist.
QA_PREBUILT="opt/LM-Studio/*"

# RDEPEND derived from two sources, cross-checked against each other:
# the .deb's own control file `Depends:` (libgtk-3-0, libnotify4, libnss3,
# libxss1, libxtst6, xdg-utils, libatspi2.0-0, libuuid1, libsecret-1-0),
# and a `scanelf -qn -R` across the *entire* extracted tree (most of the
# real ELF dependency surface is in the bundled backend .so's and the
# Electron binary itself, not just `lm-studio`). Three entries from the
# .deb's own Depends line were dropped after finding zero references to
# any of them anywhere in the whole tree (not just `lm-studio` -- grepped
# every file): x11-libs/libXtst, x11-libs/libXScrnSaver, and
# sys-apps/util-linux (the one `libuuid` string in the whole tree is
# inside the bundled CPython's libpython3.11.so, which is Python's own
# optional ctypes-based lookup with a pure-Python fallback, not a hard
# link). This looks like boilerplate electron-builder Depends cruft
# rather than a real dependency -- the same class of stale entry found on
# app-misc/claude-desktop's 1.32352.1 bump. libnotify and libsecret ARE
# genuinely used, just dlopen'd rather than linked (confirmed via string
# matches inside the `lm-studio` binary itself).
#
# Intentionally NOT listed: libcuda.so.1 (supplied by nvidia-drivers at
# runtime, dlopen'd by the CUDA backend, never a package RDEPEND -- same
# reasoning as onnxruntime/lemonade's GPU backends); media-libs/vulkan-
# loader (the whole Vulkan stack -- loader included -- is bundled: see
# resources/app/.webpack/bin/liblmstudio/vulkan/libvulkan.so.1 and the
# vendor/linux-llama-vulkan-vendor-v1 dir; some other overlays' ebuilds
# wrongly RDEPEND on it); media-gfx/vips (the `sharp` Node addon bundles
# its own libvips-cpp.so.8.17.3 right next to itself); dev-libs/dbus-glib
# (not referenced anywhere -- same finding as app-text/zotero-bin's
# Gecko, Electron's own D-Bus usage here goes through libdbus-1 only).
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
	virtual/libcrypt
	virtual/libudev
	x11-libs/cairo
	x11-libs/gtk+:3
	x11-libs/libX11
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXrandr
	x11-libs/libnotify
	x11-libs/libxcb
	x11-libs/libxkbcommon
	x11-libs/pango
	x11-misc/xdg-utils
"

src_install() {
	local backends="opt/LM-Studio/resources/app/.webpack/bin/extensions/backends"

	if ! use cuda; then
		rm -r "${backends}"/llama.cpp-linux-x86_64-nvidia-cuda-avx2-* || die
		rm -r "${backends}/vendor/linux-llama-cuda-vendor-v1" || die
	fi

	if ! use vulkan; then
		rm -r "${backends}"/llama.cpp-linux-x86_64-vulkan-avx2-* || die
		rm -r "${backends}/vendor/linux-llama-vulkan-vendor-v1" || die
		rm -r opt/LM-Studio/resources/app/.webpack/bin/liblmstudio/vulkan || die
		rm -f opt/LM-Studio/libvulkan.so.1 || die
	fi

	# cp -a preserves the executable bits already set on most of the
	# bundled binaries (lm-studio, chrome-sandbox, node, python3.11, the
	# llama-server variants, every *.so). A couple of files ship without
	# +x in the .deb itself (upstream packaging oversight, not a Gentoo
	# artifact) and need it restored explicitly.
	dodir /opt
	cp -a opt/LM-Studio "${ED}/opt/" || die "failed to install bundle"

	fperms +x /opt/LM-Studio/resources/app/.webpack/bin/deno
	fperms +x /opt/LM-Studio/resources/app/.webpack/bin/esbuild
	fperms +x /opt/LM-Studio/resources/app/.webpack/bin/libsqlite-vector.so

	# Chromium's SUID sandbox needs this setuid root where unprivileged
	# user namespaces are unavailable; 4711 (no read bit) matches how
	# ::gentoo's own Electron-based packages tighten upstream's 4755.
	fperms 4711 /opt/LM-Studio/chrome-sandbox

	# V8/JIT binary: mark so a PaX/hardened kernel permits RWX/mprotect.
	# No-op on a vanilla kernel.
	pax-mark m "${ED}/opt/LM-Studio/lm-studio"

	dosym ../../opt/LM-Studio/lm-studio /usr/bin/lm-studio
	dosym ../../opt/LM-Studio/resources/app/.webpack/lms /usr/bin/lms

	# Upstream's desktop file has three defects: a stray lowercase
	# `category=` line (not a real desktop-entry key) carrying the
	# Utility category that the real Categories= key is missing, and an
	# absolute Exec= path that we normalise to the PATH launcher instead.
	local desktop="usr/share/applications/lm-studio.desktop"
	sed -i \
		-e '/^category=/d' \
		-e 's|^Exec=.*/lm-studio |Exec=lm-studio |' \
		-e 's|^Categories=Development;$|Categories=Development;Utility;|' \
		"${desktop}" || die
	domenu "${desktop}"

	# Upstream ships one 1024x1024 icon under a bogus "0x0" hicolor dir.
	newicon -s 1024 usr/share/icons/hicolor/0x0/apps/lm-studio.png lm-studio.png
}

pkg_postinst() {
	xdg_pkg_postinst

	elog "LM Studio stores models and settings under ~/.lmstudio."
	elog "Launch it from your menu, or from a terminal with: lm-studio"
	elog "The bundled CLI is available as: lms"
	if use cuda; then
		elog
		elog "USE=cuda needs the proprietary x11-drivers/nvidia-drivers"
		elog "package installed; libcuda.so.1 is loaded from the driver at"
		elog "runtime and is intentionally not a package dependency here."
	fi
}

pkg_postrm() {
	xdg_pkg_postrm
}
