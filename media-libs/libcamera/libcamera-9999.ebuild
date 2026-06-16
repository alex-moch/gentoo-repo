# Copyright 2025-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..15} )

inherit meson python-any-r1

DESCRIPTION="Complex camera support library"
HOMEPAGE="https://libcamera.org"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://git.libcamera.org/libcamera/libcamera.git"
	# Pin to a known-good commit for reproducible rebuilds; leave unset to
	# track master HEAD. When set, the tree only changes when you change this.
	#EGIT_COMMIT=""
	# For 9999, git-r3 checks out to ${WORKDIR}/${P}, which matches the
	# default S, so no SRC_URI/S override is needed here.
else
	SRC_URI="https://gitlab.freedesktop.org/camera/libcamera/-/archive/v${PV}/libcamera-v${PV}.tar.bz2"
	S="${WORKDIR}/libcamera-v${PV}"
	KEYWORDS="amd64 arm arm64 ~riscv x86"
fi

LICENSE="Apache-2.0 CC0-1.0 BSD BSD-2 CC-BY-4.0 CC-BY-SA-4.0 GPL-2+ GPL-2 LGPL-2.1+ MIT"

# libcamera uses the major and minor version components as the soname.
# See: https://gitlab.freedesktop.org/camera/libcamera/-/blob/v0.6.0/meson.build?ref_type=tags#L59
#
# For the live ebuild the subslot resolves to "9999", so consumers linked
# against libcamera (gst-plugin, pipewire, ...) will NOT be auto-rebuilt when
# the master soname bumps. After a major master jump, rebuild them yourself:
#   emerge -1 @preserved-rebuild
SLOT="0/${PV}"
IUSE="drm elfutils gstreamer gui jpeg openssl sdl test tiff tools trace +udev unwind v4l"
RESTRICT="
	!test? ( test )
"
REQUIRED_USE="
	jpeg? ( sdl )
	sdl? ( gui )
	test? ( udev )
"

# 'dev-cpp/gtest' is required as runtime dependency because it's used by lc-compliance tool
#
# IPA-module signature verification picks its crypto backend automatically
# (master prefers gnutls, falling back to libcrypto from OpenSSL) — there is no
# meson option for it. The 'openssl' USE flag only governs which library we make
# available to that auto-detection, so make exactly one present to keep the
# choice deterministic.
COMMON_DEPEND="
	dev-libs/libyaml
	elfutils? ( dev-libs/elfutils )
	gstreamer? (
		dev-libs/glib:2
		>=media-libs/gstreamer-1.14.0:1.0
		>=media-libs/gst-plugins-base-1.14:1.0
	)
	!openssl? ( net-libs/gnutls:= )
	openssl? ( dev-libs/openssl:= )
	tools? (
		dev-cpp/gtest:=
		dev-libs/libevent:=
		drm? ( x11-libs/libdrm )
		gui? (
			dev-qt/qtbase:6[gui,opengl,widgets]
			sdl? (
				media-libs/libsdl2
				jpeg? ( media-libs/libjpeg-turbo:= )
			)
		)
		tiff? ( media-libs/tiff:= )
	)
	trace? (
		dev-util/lttng-ust:=
	)
	udev? ( virtual/libudev:= )
	unwind? ( sys-libs/libunwind:= )
"

DEPEND="
	${COMMON_DEPEND}
	test? ( media-libs/libyuv:= )
"

RDEPEND="
	${COMMON_DEPEND}
"

# 'dev-libs/openssl' is called by src/ipa/ipa-sign.sh to sign IPA modules
BDEPEND="
	${PYTHON_DEPS}
	$(python_gen_any_dep '
		dev-python/jinja2[${PYTHON_USEDEP}]
		dev-python/ply[${PYTHON_USEDEP}]
		dev-python/pyyaml[${PYTHON_USEDEP}]
	')
	dev-libs/openssl
"

# NOTE: The release-specific patches from libcamera-0.7.0-r1 (no-automagic-flags,
# disable-problematic-tests) are intentionally NOT carried here: they are pinned
# to the 0.7.0 tree and will not apply to a moving master checkout.
#
# The ov08x40 software-ISP sensor helper (upstream patchwork 26747) is provided
# as an OPTIONAL patch. First check whether master already has it:
#   grep -q Ov08x40 "${S}"/src/ipa/libipa/camera_sensor_helper.cpp
# If that prints nothing, uncomment the line below and drop the patch into
# files/. If it's already merged, leave this commented out.
PATCHES=(
	#"${FILESDIR}"/${PN}-ov08x40-sensor-helper.patch
)

python_check_deps() {
	python_has_version "dev-python/jinja2[${PYTHON_USEDEP}]" &&
	python_has_version "dev-python/ply[${PYTHON_USEDEP}]" &&
	python_has_version "dev-python/pyyaml[${PYTHON_USEDEP}]"
}

src_configure() {
	local emesonargs=(
		# Broken for >=dev-python/sphinx-7
		# $(meson_feature doc documentation)
		-Ddocumentation=disabled
		# TODO: Python bindings are disabled for now since they are experimental
		-Dpycamera=disabled
		# TODO: Skipping 'rpi/pisp' and 'virtual' pipelines.
		# 	- Pipeline 'rpi/pisp' depends on libpisp not available in Gentoo repository yet.
		# 	- Pipeline 'virtual' depends on libyuv but seems to be only used during tests.
		-Dpipelines=imx8-isi,ipu3,mali-c55,rkisp1,rpi/vc4,simple,uvcvideo,vimc
		$(meson_feature tools cam)
		$(meson_feature tools lc-compliance)
		$(meson_feature drm cam-output-kms)
		$(meson_feature sdl cam-output-sdl2)
		$(meson_feature jpeg cam-jpeg)
		$(meson_feature tiff apps-output-dng)
		$(meson_feature gstreamer)
		# No crypto-backend option exists; libcamera auto-detects gnutls
		# or libcrypto. See the COMMON_DEPEND note above.
		$(meson_feature trace tracing)
		$(meson_feature unwind libunwind)
		$(meson_feature elfutils libdw)
		$(meson_feature udev)
		$(meson_feature v4l v4l2)
		$(meson_use test)
	)

	# QCam requires both tools & gui USE flags to be enabled
	if use tools && use gui; then
		emesonargs+=(
			-Dqcam=enabled
		)
	else
		emesonargs+=(
			-Dqcam=disabled
		)
	fi

	meson_src_configure
}

src_install() {
	meson_src_install

	# Exclude IPA signed modules from stripping process
	# Note: This is required to prevent strip tool to invalidate their signature
	dostrip -x "/usr/$(get_libdir)/libcamera/ipa/"
}
