# Copyright 2024-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="Local LLM serving with GPU and NPU acceleration"
HOMEPAGE="https://lemonade-server.ai/ https://github.com/lemonade-sdk/lemonade"
SRC_URI="https://github.com/lemonade-sdk/lemonade/archive/refs/tags/v${PV}.tar.gz -> ${P}.gh.tar.gz"
S="${WORKDIR}/lemonade-${PV}"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+systemd +webapp"

# network-sandbox: with USE=webapp, the web app's build step runs `npm ci`
# against the npm registry. Gentoo has no equivalent of cargo.eclass for
# vendoring npm dependencies offline, so that build is not hermetic.
RESTRICT="test webapp? ( network-sandbox )"

# dev-cpp/cli11 and dev-cpp/nlohmann_json are header-only libs detected via
# find_package(); dev-cpp/cpp-httplib ships a CMake package config rather
# than a .pc file, so PATCHES adds a find_package(CONFIG) fallback for it
# (upstream only probes pkg-config). The server links against system
# libcurl/libwebsockets/mbedtls/libzstd/libcap/libdrm_amdgpu (unconditionally)
# and libsystemd (systemd USE flag) instead of upstream's FetchContent
# fallback; these are compiled at both build and run time, hence
# COMMON_DEPEND. x11-libs/libdrm went from a header-only DEPEND (raw ioctl
# calls against its UAPI headers) to an actual link as of 11.0.0
# (server/backends/ryzenai's NPU sensor query).
COMMON_DEPEND="
	net-libs/libwebsockets
	net-libs/mbedtls
	net-misc/curl
	app-arch/zstd
	sys-libs/libcap
	x11-libs/libdrm[video_cards_amdgpu]
	systemd? ( sys-apps/systemd )
"
DEPEND="
	${COMMON_DEPEND}
	dev-cpp/cli11
	dev-cpp/cpp-httplib
	dev-cpp/nlohmann_json
"
# jq/xdg-utils (webapp? below) are runtime deps of the "lemonade-web-app"
# browser-launcher script + .desktop entry that upstream installs alongside
# the web app itself (opens a browser to the running server's UI). A
# preferred Chromium-based browser is checked for at runtime but not
# required — the script falls back to xdg-open.
RDEPEND="
	${COMMON_DEPEND}
	acct-group/lemonade
	acct-user/lemonade
	app-arch/unzip
	webapp? (
		app-misc/jq
		x11-misc/xdg-utils
	)
"
BDEPEND="
	virtual/pkgconfig
	webapp? ( net-libs/nodejs[npm] )
"

PATCHES=(
	"${FILESDIR}/${P}-system-httplib-config.patch"
	"${FILESDIR}/${P}-system-mbedcrypto-slot.patch"
)

src_configure() {
	local mycmakeargs=(
		-DBUILD_WEB_APP=$(usex webapp)
		-DBUILD_TAURI_APP=OFF
		-DBUILD_TESTING=OFF
	)
	cmake_src_configure
}

src_install() {
	cmake_src_install

	# Upstream also installs a sysusers.d snippet to create the 'lemonade'
	# system user via systemd-sysusers; acct-group/acct-user already do this
	# through Gentoo's own mechanism, so drop it to avoid two independent
	# user-creation paths racing at boot.
	rm -r "${ED}/usr/lib/sysusers.d" || die

	newinitd "${FILESDIR}/lemonade-server.init" "${PN}"
}

pkg_preinst() {
	keepdir /var/lib/lemonade
	fowners lemonade:lemonade /var/lib/lemonade
	fperms 0750 /var/lib/lemonade
}

pkg_postinst() {
	if [[ -z ${REPLACING_VERSIONS} ]]; then
		einfo "Quick guide:"
		einfo "\trc-service ${PN} start   # OpenRC"
		einfo "\tsystemctl start lemond   # systemd"
		einfo
		if use webapp; then
			einfo "The web UI is at http://localhost:13305 by default."
		else
			einfo "The API is at http://localhost:13305 by default (USE=-webapp:"
			einfo "no web UI, just a static status page)."
		fi
		einfo "See https://lemonade-server.ai/docs/ for backend setup (llama.cpp,"
		einfo "FastFlowLM, RyzenAI, ...) and model management."
	fi
}
