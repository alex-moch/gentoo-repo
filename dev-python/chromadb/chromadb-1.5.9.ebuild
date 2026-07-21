# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
# There is no real PEP517 build here -- see python_compile() below. The
# actual native code (chromadb_rust_bindings, a ~1020-crate Rust/PyO3
# workspace) is only ever published as a prebuilt wheel; upstream's sdist
# doesn't even attempt a source build path for it. Rather than vendor that
# entire crate graph, this installs the real manylinux wheel directly.
DISTUTILS_USE_PEP517=no

inherit distutils-r1 pypi

DESCRIPTION="AI-native open-source embedding database"
HOMEPAGE="
	https://www.trychroma.com/
	https://github.com/chroma-core/chroma
	https://pypi.org/project/chromadb/
"

# cp39-abi3: built against the stable Python ABI, so this one wheel covers
# every PYTHON_COMPAT target without a per-version fetch.
PY_TAG="cp39"
ABI_TAG="abi3-manylinux_2_17_x86_64.manylinux2014_x86_64"
WHEEL_FILENAME="$(pypi_wheel_name "${PN}" "${PV}" "${PY_TAG}" "${ABI_TAG}")"

SRC_URI="$(pypi_wheel_url "${PN}" "${PV}" "${PY_TAG}" "${ABI_TAG}")"
S="${WORKDIR}"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

# Verified via `scanelf -qn` on the extracted .so: only libc/libm/libpthread/
# libdl/ld-linux -- every one of the ~1020 Rust crates is statically linked
# in, so there is no RDEPEND on any native library, unlike e.g.
# dev-util/semgrep-core-bin's bundled-shared-libs situation.
RDEPEND="
	>=dev-python/pydantic-2.0[${PYTHON_USEDEP}]
	>=dev-python/pydantic-settings-2.0[${PYTHON_USEDEP}]
	>=dev-python/pybase64-1.4.1[${PYTHON_USEDEP}]
	>=dev-python/uvicorn-0.18.3[${PYTHON_USEDEP}]
	>=dev-python/numpy-1.22.5[${PYTHON_USEDEP}]
	>=dev-python/typing-extensions-4.5.0[${PYTHON_USEDEP}]
	>=sci-libs/onnxruntime-1.14.1[python,${PYTHON_USEDEP}]
	>=dev-python/opentelemetry-api-1.2.0[${PYTHON_USEDEP}]
	>=dev-python/opentelemetry-exporter-otlp-proto-grpc-1.2.0[${PYTHON_USEDEP}]
	>=dev-python/opentelemetry-sdk-1.2.0[${PYTHON_USEDEP}]
	sci-ml/tokenizers
	>=dev-python/pypika-0.48.9[${PYTHON_USEDEP}]
	>=dev-python/tqdm-4.65.0[${PYTHON_USEDEP}]
	>=dev-python/overrides-7.3.1[${PYTHON_USEDEP}]
	dev-python/importlib-resources[${PYTHON_USEDEP}]
	>=dev-python/grpcio-1.58.0[${PYTHON_USEDEP}]
	>=dev-python/bcrypt-4.0.1[${PYTHON_USEDEP}]
	>=dev-python/typer-0.9.0[${PYTHON_USEDEP}]
	>=dev-python/kubernetes-28.1.0[${PYTHON_USEDEP}]
	>=dev-python/tenacity-8.2.3[${PYTHON_USEDEP}]
	>=dev-python/pyyaml-6.0.0[${PYTHON_USEDEP}]
	>=dev-python/mmh3-4.0.1[${PYTHON_USEDEP}]
	>=dev-python/orjson-3.9.12[${PYTHON_USEDEP}]
	>=dev-python/httpx-0.27.0[${PYTHON_USEDEP}]
	>=dev-python/rich-10.11.0[${PYTHON_USEDEP}]
	>=dev-python/jsonschema-4.19.0[${PYTHON_USEDEP}]
"

RESTRICT="test strip"

QA_PREBUILT="usr/lib/python*/site-packages/chromadb_rust_bindings/chromadb_rust_bindings.abi3.so"

src_unpack() {
	# Nothing to extract -- the wheel stays a raw distfile; python_compile
	# installs it directly.
	:
}

python_compile() {
	distutils_wheel_install "${BUILD_DIR}/install" "${DISTDIR}/${WHEEL_FILENAME}"
}
