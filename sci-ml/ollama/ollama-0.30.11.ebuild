# Copyright 2024-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# supports ROCM/HIP >=5.5, but we define 6.1 due to the eclass
ROCM_VERSION="6.1"
inherit cuda rocm
inherit cmake
inherit flag-o-matic go-module linux-info systemd toolchain-funcs

DESCRIPTION="Get up and running with Llama 3, Mistral, Gemma, and other language models."
HOMEPAGE="https://ollama.com"

# Pinned llama.cpp revision. Must match the contents of the upstream
# ${S}/LLAMA_CPP_VERSION file; src_prepare verifies this. llama.cpp tags
# releases as bNNNN, so the tag doubles as the archive name.
LLAMA_CPP_COMMIT="b9781"

if [[ ${PV} == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/ollama/ollama.git"
	# The live ebuild still needs the pinned llama.cpp tarball offline.
	# src_prepare verifies LLAMA_CPP_COMMIT against the checkout's
	# LLAMA_CPP_VERSION and dies if master has moved the pin (bump
	# LLAMA_CPP_COMMIT, then re-manifest, when that happens).
	SRC_URI="
		https://github.com/ggml-org/llama.cpp/archive/refs/tags/${LLAMA_CPP_COMMIT}.tar.gz
			-> llama.cpp-${LLAMA_CPP_COMMIT}.tar.gz
	"
else
	MY_PV="${PV/_rc/-rc}"
	MY_P="${PN}-${MY_PV}"
	SRC_URI="
		https://github.com/ollama/${PN}/archive/refs/tags/v${MY_PV}.tar.gz -> ${MY_P}.gh.tar.gz
		https://github.com/gentoo-golang-dist/${PN}/releases/download/v${MY_PV}/${MY_P}-deps.tar.xz
		https://github.com/ggml-org/llama.cpp/archive/refs/tags/${LLAMA_CPP_COMMIT}.tar.gz
			-> llama.cpp-${LLAMA_CPP_COMMIT}.tar.gz
	"
	if [[ ${PV} != *_rc* ]]; then
		KEYWORDS="~amd64"
	fi
fi

# Upstream now fetches llama.cpp at configure time via FetchContent; we
# supply it offline instead and point the build at this tree.
LLAMA_CPP_S="${WORKDIR}/llama.cpp-${LLAMA_CPP_COMMIT}"

LICENSE="MIT"
SLOT="0"

IUSE="cuda rocm vulkan"

BLAS_BACKENDS="blis mkl openblas"
BLAS_REQUIRED_USE="
	blas? ( ?? ( ${BLAS_BACKENDS} ) )
	flexiblas? ( blas )
	blis? ( blas )
	mkl? ( blas )
	openblas? ( blas )
"

IUSE+=" blas flexiblas ${BLAS_BACKENDS}"
REQUIRED_USE+=" ${BLAS_REQUIRED_USE}"

RESTRICT="mirror test"

# FindBLAS.cmake
# If Fortran is an enabled compiler it sets BLAS_mkl_THREADING to gnu. -> sci-libs/mkl[gnu-openmp]
# If Fortran is not an enabled compiler it sets BLAS_mkl_THREADING to intel. -> sci-libs/mkl[llvm-openmp]
COMMON_DEPEND="
	blas? (
		blis? (
			sci-libs/blis:=
		)
		flexiblas? (
			sci-libs/flexiblas[blis?,mkl?,openblas?]
		)
		mkl? (
			sci-libs/mkl[llvm-openmp]
		)
		openblas? (
			sci-libs/openblas
		)
		virtual/blas[flexiblas=]
	)
	cuda? (
		dev-util/nvidia-cuda-toolkit:=
	)
	rocm? (
		>=dev-util/hip-${ROCM_VERSION}:=
		>=sci-libs/hipBLAS-${ROCM_VERSION}:=
		>=sci-libs/rocBLAS-${ROCM_VERSION}:=
	)
	vulkan? (
		media-libs/vulkan-loader
	)
"

DEPEND="
	${COMMON_DEPEND}
"
BDEPEND="
	>=dev-lang/go-1.26.0
	vulkan? (
		dev-util/vulkan-headers
		media-libs/shaderc
	)
"

RDEPEND="
	${COMMON_DEPEND}
	acct-group/${PN}
	>=acct-user/${PN}-3[cuda?]
"

pkg_setup() {
	if use rocm; then
		linux-info_pkg_setup
		if linux-info_get_any_version && linux_config_exists; then
			if ! linux_chkconfig_present HSA_AMD_SVM; then
				ewarn "To use ROCm/HIP, you need to have HSA_AMD_SVM option enabled in your kernel."
			fi
		fi
	fi
}

src_unpack() {
	# Already filter lto flags for ROCM
	# 963401
	if use rocm; then
		# copied from _rocm_strip_unsupported_flags
		strip-unsupported-flags
		export CXXFLAGS="$(test-flags-HIPCXX "${CXXFLAGS}")"
	fi

	if [[ "${PV}" == *9999* ]]; then
		git-r3_src_unpack
		go-module_live_vendor
		# git-r3 only unpacks the repository; the llama.cpp tarball from
		# SRC_URI still needs to be extracted into ${WORKDIR}.
		unpack "llama.cpp-${LLAMA_CPP_COMMIT}.tar.gz"
	else
		go-module_src_unpack
	fi
}

src_prepare() {
	cmake_src_prepare

	# The bundled llama.cpp revision must match the one upstream pinned,
	# otherwise the compat patch and ABI assumptions break.
	local pinned
	pinned="$(<LLAMA_CPP_VERSION)" || die "cannot read LLAMA_CPP_VERSION"
	if [[ ${pinned} != "${LLAMA_CPP_COMMIT}" ]]; then
		die "llama.cpp pin mismatch: ebuild has ${LLAMA_CPP_COMMIT}, upstream wants ${pinned}"
	fi

	# The Go binary locates its runtime payload relative to the executable
	# (../lib/ollama). Rewrite the hardcoded "lib" segment to honour
	# multilib so the libraries are found under $(get_libdir)/ollama.
	# grep -Rl '"lib", "ollama"' --include '*.go'
	sed -i \
		-e "s/\"lib\", \"ollama\"/\"$(get_libdir)\", \"ollama\"/g" \
		ml/path.go discover/types.go \
		|| die "libdir sed failed"

	if use cuda; then
		cuda_src_prepare
	fi

	if use rocm; then
		# Upstream forces CMAKE_HIP_FLAGS to "-parallel-jobs=4", an
		# amdclang/hipcc-only option. Gentoo compiles HIP with the system
		# LLVM clang, which rejects it ("unknown argument: '-parallel-jobs'")
		# and aborts the enable_language(HIP) probe. Drop the flag.
		sed -i \
			-e 's/-parallel-jobs=4//g' \
			llama/server/CMakeLists.txt \
			|| die "parallel-jobs sed failed"
	fi
}

# Configure and build one llama-server runner variant. The first invocation
# applies upstream's llama.cpp compat patch to ${LLAMA_CPP_S}; it is
# idempotent, so subsequent runners reuse the same patched source tree.
_ollama_native_build() {
	local runner=${1}

	local CMAKE_USE_DIR="${S}/llama/server"
	local BUILD_DIR="${WORKDIR}/build-${runner}"
	local -a targets mycmakeargs

	# We de-bundle the GPU vendor runtimes (see src_install). Upstream's
	# install RPATH is already "$ORIGIN"; for cpu/rocm/vulkan that is all we
	# need (rocm resolves through the system /usr/lib64), so stop CMake from
	# also appending build-tree link directories that portage flags as
	# insecure. The cuda backend is the exception: cublas/cudart live outside
	# the default linker path, so it keeps the link directories enabled to
	# bake the resolved toolkit libdir into its RUNPATH (set ON below).
	local rpath_use_link=OFF

	mycmakeargs=(
		-DBUILD_SHARED_LIBS=ON
		-DGGML_BACKEND_DL=ON
		# Honour CFLAGS/CXXFLAGS rather than -march=native.
		-DGGML_NATIVE=OFF
		-DGGML_OPENMP=OFF
		-DOLLAMA_LIB_DIR="$(get_libdir)/ollama"
		-DFETCHCONTENT_SOURCE_DIR_LLAMA_CPP="${LLAMA_CPP_S}"
	)

	case ${runner} in
	cpu)
		# Build all CPU micro-architecture backends; ggml selects the best
		# one at runtime via GGML_BACKEND_DL.
		mycmakeargs+=(
			-DGGML_CPU_ALL_VARIANTS=ON
			-DOLLAMA_RUNNER_DIR=""
			-DGGML_BLAS="$(usex blas)"
		)
		if use blas; then
			local vendor=Generic
			if use flexiblas; then
				vendor=FlexiBLAS
			elif use blis; then
				vendor=FLAME
			elif use mkl; then
				vendor=Intel10_64lp
			elif use openblas; then
				vendor=OpenBLAS
			fi
			mycmakeargs+=( -DGGML_BLAS_VENDOR="${vendor}" )
		fi
		targets=( llama-server )
		;;
	vulkan)
		mycmakeargs+=(
			-DGGML_VULKAN=ON
			-DOLLAMA_GPU_BACKEND=vulkan
			-DOLLAMA_RUNNER_DIR="vulkan"
		)
		targets=( ggml-vulkan )
		;;
	cuda)
		local -x CUDAHOSTCXX CUDAHOSTLD
		CUDAHOSTCXX="$(cuda_gccdir)"
		CUDAHOSTLD="$(tc-getCXX)"

		# default to all-major for now until cuda.eclass is updated
		local CUDAARCHS=${CUDAARCHS:-all-major}

		mycmakeargs+=(
			-DGGML_CUDA=ON
			-DOLLAMA_GPU_BACKEND=cuda
			-DOLLAMA_RUNNER_DIR="cuda_v12"
			-DCMAKE_CUDA_ARCHITECTURES="${CUDAARCHS}"
		)
		targets=( ggml-cuda )
		# Keep the resolved CUDA toolkit libdir in the backend's RUNPATH,
		# since the bundled cublas/cudart copies are pruned in src_install.
		rpath_use_link=ON

		cuda_add_sandbox -w
		addpredict "/dev/char/"
		;;
	rocm)
		local -x HIP_PATH="${ESYSROOT}/usr"
		mycmakeargs+=(
			-DGGML_HIP=ON
			-DOLLAMA_GPU_BACKEND=hip
			-DOLLAMA_RUNNER_DIR="rocm_v7_2"
			-DCMAKE_HIP_PLATFORM="amd"
			-DCMAKE_HIP_ARCHITECTURES="$(get_amdgpu_flags)"
			-DAMDGPU_TARGETS="$(get_amdgpu_flags)"
		)
		targets=( ggml-hip )
		;;
	esac

	mycmakeargs+=( -DCMAKE_INSTALL_RPATH_USE_LINK_PATH=${rpath_use_link} )

	cmake_src_configure
	cmake_build "${targets[@]}"
}

# Runners to build for the current USE configuration. CPU is always built.
_ollama_active_runners() {
	local runners="cpu"
	use vulkan && runners+=" vulkan"
	use cuda && runners+=" cuda"
	use rocm && runners+=" rocm"
	echo "${runners}"
}

src_compile() {
	# Build the Go front-end binary. The native runtime (llama-server and
	# the ggml backends) is built separately below and discovered at
	# runtime under $(get_libdir)/ollama.
	local VERSION
	if [[ "${PV}" == *9999* ]]; then
		VERSION="$(
			git describe --tags --first-parent --abbrev=7 --long --dirty --always \
			| sed -e "s/^v//g"
		)"
	else
		VERSION="${PV}"
	fi
	local EXTRA_GOFLAGS_LD=(
		"-X=github.com/ollama/ollama/version.Version=${VERSION}"
		"-X=github.com/ollama/ollama/server.mode=release"
	)
	GOFLAGS+=" '-ldflags=${EXTRA_GOFLAGS_LD[*]}'"

	ego build

	local runner
	for runner in $(_ollama_active_runners); do
		_ollama_native_build "${runner}"
	done
}

src_install() {
	dobin ollama

	local runner
	for runner in $(_ollama_active_runners); do
		DESTDIR="${D}" cmake --install "${WORKDIR}/build-${runner}" \
			--component llama-server || die "install of ${runner} runner failed"
	done

	# Upstream bundles the GPU vendor runtime libraries next to each backend
	# (CUDA's cublas/cudart; ROCm's amdhip64/rocblas/hipblas/rocsolver/
	# hsa-runtime64 plus libdrm, libelf and the rocBLAS Tensile kernels) so
	# the release tarball is self-contained. On Gentoo those are owned by the
	# packages we depend on, so drop the bundled copies and keep only the
	# ggml backend module; the dynamic linker resolves the rest from the
	# system (ROCm via /usr/lib64, CUDA via the RUNPATH baked in at build
	# time). This also clears the "pre-stripped files" QA notice.
	local gpu_libdir="${ED}/usr/$(get_libdir)/ollama"
	if use cuda; then
		find "${gpu_libdir}/cuda_v12" -mindepth 1 ! -name 'libggml-cuda.so*' \
			-delete || die "failed to prune bundled CUDA libraries"
	fi
	if use rocm; then
		find "${gpu_libdir}/rocm_v7_2" -mindepth 1 ! -name 'libggml-hip.so*' \
			-delete || die "failed to prune bundled ROCm libraries"
	fi

	newinitd "${FILESDIR}/ollama.init" "${PN}"
	newconfd "${FILESDIR}/ollama.confd" "${PN}"

	systemd_dounit "${FILESDIR}/ollama.service"
}

pkg_preinst() {
	keepdir /var/log/ollama
	fperms 750 /var/log/ollama
	fowners "${PN}:${PN}" /var/log/ollama
}

pkg_postinst() {
	if [[ -z ${REPLACING_VERSIONS} ]] ; then
		einfo "Quick guide:"
		einfo "\tollama serve"
		einfo "\tollama run llama3:70b"
		einfo
		einfo "See available models at https://ollama.com/library"
	fi

	einfo
	einfo "Ollama binds 127.0.0.1 port 11434 by default."
	einfo "Change the bind address with the OLLAMA_HOST environment variable."
	einfo "See https://docs.ollama.com/faq for more info"
	einfo

	if use cuda ; then
		einfo "When using cuda the user running ${PN} has to be in the video group or it won't detect devices."
		einfo "The ebuild ensures this for user ${PN} via acct-user/${PN}[cuda]"
	fi
}
