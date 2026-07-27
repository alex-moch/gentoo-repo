# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
# Upstream has never published an sdist for this package -- install the
# real py3-none-any wheel directly, same mechanism as dev-python/lfx,
# dev-python/langflow-sdk, and dev-python/chromadb.
DISTUTILS_USE_PEP517=no

inherit distutils-r1 pypi

DESCRIPTION="Langflow's Python backend -- a package with a built-in web application"
HOMEPAGE="
	https://github.com/langflow-ai/langflow
	https://pypi.org/project/langflow-base/
"

WHEEL_FILENAME="$(pypi_wheel_name "${PN}" "${PV}")"

SRC_URI="$(pypi_wheel_url "${PN}" "${PV}")"
S="${WORKDIR}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="anthropic google-genai ollama openai weaviate"

# httpx's [http2] extra has no corresponding USE flag on this tree's
# dev-python/httpx -- translated to a hard dep on dev-python/h2, same as
# elsewhere in this overlay.
#
# langchain-ibm/ibm-watsonx-ai is a real upstream RDEPEND entry,
# deliberately omitted entirely with no USE flag: ibm-watsonx-ai needs a
# 5-package IBM Cloud Object Storage SDK chain (lomond, ibm-cos-sdk,
# ibm-cos-sdk-core, ibm-cos-sdk-s3transfer) not packaged anywhere in this
# overlay, GURU, or the main tree -- a USE flag here would just reference
# nonexistent atoms, worse than the current silent omission.
#
# langchain-weaviate/weaviate-client IS packaged, just genuinely
# uninstallable by default (weaviate-client pins grpcio<1.80.0, and this
# tree only carries 1.80.0+) -- gated behind IUSE="weaviate" (default
# off) instead of silent omission, so the capability is discoverable via
# `equery uses` and needs zero ebuild rework once the grpcio conflict
# resolves. Verified at runtime (real launch test) that Langflow's
# component registry lazily imports each integration rather than doing
# an eager import at startup, so both this and the ibm omission are
# runtime-safe, not just build-time-convenient.
#
# openai/anthropic/ollama/google-genai are all genuinely optional
# upstream (langflow-base's own [openai]/[anthropic]/[ollama]/[google]
# extras), gated the same way -- all four already fully packaged and
# working from an earlier, unrelated LangChain-provider session.
# "google-genai" is deliberately NOT named "google" to match upstream's
# own extra name: that extra also needs langchain-google-vertexai/
# -community/-calendar-tools and google-api-python-client, none of which
# are packaged here -- this flag only covers the Gemini integration that
# IS fully packaged and working. ollama/google-genai's real upstream
# ceilings (langchain-ollama~=0.3.10, langchain-google-genai~=4.1.2) are
# both exceeded by what's actually packaged (1.1.0, 4.2.7 -- packaged
# for that earlier, unrelated session, not specifically to satisfy this
# extra), so both are gated at just their real floor with no ceiling,
# same class of deviation as the version-constraint gaps below.
#
# Several atoms below are loosened from langflow-base's real upstream pin
# because the tree has moved past what it was tested against, in either
# direction, with no other version available to satisfy the real range --
# same kind of documented, unverified-but-reasonable deviation as the
# wcmatch floor relaxation in CLAUDE.md's semgrep bump procedure:
#   - structlog:     real pin <26.0.0, tree only has 26.1.0+
#   - rich:          real pin <14.0.0, tree only has 14.3.4+
#   - bcrypt:        real pin ==4.0.1 exact, tree has 4.3.0/5.0.0
#   - aiofiles:      real pin <25.0.0, tree only has 25.1.0+
#   - setuptools:    real pin [80.0.0,81.0.0), tree has 79.0.1/82.0.1/83.0.0
#   - chardet:       real pin >=7.3.0, tree only has 6.0.0_p1 (older, not newer)
#   - transformers:  real pin >=5.6.0, tree only has up to 5.3.0 (older, not newer)
RDEPEND="
	>=dev-python/lfx-1.10.2[${PYTHON_USEDEP}]
	<dev-python/lfx-1.11[${PYTHON_USEDEP}]
	>=dev-python/fastapi-0.135.0[${PYTHON_USEDEP}]
	<dev-python/fastapi-1[${PYTHON_USEDEP}]
	>=dev-python/slowapi-0.1.9[${PYTHON_USEDEP}]
	<dev-python/slowapi-1[${PYTHON_USEDEP}]
	>=dev-python/httpx-0.27[${PYTHON_USEDEP}]
	<dev-python/httpx-1[${PYTHON_USEDEP}]
	dev-python/h2[${PYTHON_USEDEP}]
	>=dev-python/aiofile-3.9.0[${PYTHON_USEDEP}]
	<dev-python/aiofile-4[${PYTHON_USEDEP}]
	>=dev-python/uvicorn-0.30.0[${PYTHON_USEDEP}]
	<dev-python/uvicorn-1[${PYTHON_USEDEP}]
	>=www-servers/gunicorn-25.3.0[${PYTHON_USEDEP}]
	<www-servers/gunicorn-27[${PYTHON_USEDEP}]
	>=dev-python/langchain-1.3.0[${PYTHON_USEDEP}]
	<dev-python/langchain-1.4[${PYTHON_USEDEP}]
	>=dev-python/langchain-community-0.4.1[${PYTHON_USEDEP}]
	<dev-python/langchain-community-0.5[${PYTHON_USEDEP}]
	>=dev-python/langchain-mongodb-0.11.0[${PYTHON_USEDEP}]
	>=dev-python/langchain-perplexity-1.0.0[${PYTHON_USEDEP}]
	<dev-python/langchain-perplexity-2[${PYTHON_USEDEP}]
	>=dev-python/langchain-qdrant-1.0.0[${PYTHON_USEDEP}]
	<dev-python/langchain-qdrant-2[${PYTHON_USEDEP}]
	>=dev-python/langchain-core-1.3.3[${PYTHON_USEDEP}]
	<dev-python/langchain-core-2[${PYTHON_USEDEP}]
	>=dev-python/langchainhub-0.1.15[${PYTHON_USEDEP}]
	<dev-python/langchainhub-0.2[${PYTHON_USEDEP}]
	>=dev-python/loguru-0.7.1[${PYTHON_USEDEP}]
	<dev-python/loguru-1[${PYTHON_USEDEP}]
	>=dev-python/structlog-25.4.0[${PYTHON_USEDEP}]
	>=dev-python/rich-13.7.0[${PYTHON_USEDEP}]
	>=dev-python/langchain-experimental-0.4.1[${PYTHON_USEDEP}]
	<dev-python/langchain-experimental-0.5[${PYTHON_USEDEP}]
	>=dev-python/sqlmodel-0.0.37[${PYTHON_USEDEP}]
	<dev-python/sqlmodel-0.1[${PYTHON_USEDEP}]
	>=dev-python/pydantic-2.13.0[${PYTHON_USEDEP}]
	<dev-python/pydantic-3[${PYTHON_USEDEP}]
	>=dev-python/pydantic-settings-2.2.0[${PYTHON_USEDEP}]
	<dev-python/pydantic-settings-3[${PYTHON_USEDEP}]
	>=dev-python/email-validator-2.0.0[${PYTHON_USEDEP}]
	>=dev-python/typer-0.13.0[${PYTHON_USEDEP}]
	<dev-python/typer-1[${PYTHON_USEDEP}]
	>=dev-python/cachetools-6.0.0[${PYTHON_USEDEP}]
	>=dev-python/platformdirs-4.2.0[${PYTHON_USEDEP}]
	<dev-python/platformdirs-5[${PYTHON_USEDEP}]
	>=dev-python/python-multipart-0.0.12[${PYTHON_USEDEP}]
	<dev-python/python-multipart-1[${PYTHON_USEDEP}]
	>=dev-python/orjson-3.11.6[${PYTHON_USEDEP}]
	<dev-python/orjson-4[${PYTHON_USEDEP}]
	>=dev-python/alembic-1.13.0[${PYTHON_USEDEP}]
	<dev-python/alembic-2[${PYTHON_USEDEP}]
	>=dev-python/libpass-1.7.4[${PYTHON_USEDEP}]
	<dev-python/libpass-2[${PYTHON_USEDEP}]
	>=dev-python/bcrypt-4.0.1[${PYTHON_USEDEP}]
	>=dev-python/pillow-12.1.1[${PYTHON_USEDEP}]
	<dev-python/pillow-13[${PYTHON_USEDEP}]
	>=dev-python/docstring-parser-0.16[${PYTHON_USEDEP}]
	<dev-python/docstring-parser-1[${PYTHON_USEDEP}]
	>=dev-python/pyjwt-2.12.1[${PYTHON_USEDEP}]
	>=dev-python/pandas-2.2.3[${PYTHON_USEDEP}]
	>=dev-python/multiprocess-0.70.14[${PYTHON_USEDEP}]
	<dev-python/multiprocess-1[${PYTHON_USEDEP}]
	>=dev-python/duckdb-1.0.0[${PYTHON_USEDEP}]
	<dev-python/duckdb-2[${PYTHON_USEDEP}]
	>=dev-python/python-docx-1.1.0[${PYTHON_USEDEP}]
	<dev-python/python-docx-2[${PYTHON_USEDEP}]
	>=dev-python/jq-1.7.0[${PYTHON_USEDEP}]
	<dev-python/jq-2[${PYTHON_USEDEP}]
	>=dev-python/nest-asyncio-1.6.0[${PYTHON_USEDEP}]
	<dev-python/nest-asyncio-2[${PYTHON_USEDEP}]
	>=dev-python/emoji-2.12.0[${PYTHON_USEDEP}]
	<dev-python/emoji-3[${PYTHON_USEDEP}]
	>=dev-python/cryptography-48.0.1[${PYTHON_USEDEP}]
	>=dev-python/asyncer-0.0.5[${PYTHON_USEDEP}]
	<dev-python/asyncer-1[${PYTHON_USEDEP}]
	>=dev-python/pyperclip-1.8.2[${PYTHON_USEDEP}]
	<dev-python/pyperclip-2[${PYTHON_USEDEP}]
	>=dev-python/uncurl-0.0.11[${PYTHON_USEDEP}]
	<dev-python/uncurl-1[${PYTHON_USEDEP}]
	>=dev-python/sentry-sdk-2.5.1[${PYTHON_USEDEP}]
	<dev-python/sentry-sdk-3[${PYTHON_USEDEP}]
	dev-python/chardet[${PYTHON_USEDEP}]
	>=dev-python/firecrawl-py-1.0.16[${PYTHON_USEDEP}]
	<dev-python/firecrawl-py-2[${PYTHON_USEDEP}]
	>=dev-python/opentelemetry-api-1.30.0[${PYTHON_USEDEP}]
	<dev-python/opentelemetry-api-2[${PYTHON_USEDEP}]
	>=dev-python/opentelemetry-sdk-1.30.0[${PYTHON_USEDEP}]
	<dev-python/opentelemetry-sdk-2[${PYTHON_USEDEP}]
	>=dev-python/opentelemetry-exporter-prometheus-0.64_beta0[${PYTHON_USEDEP}]
	>=dev-python/opentelemetry-exporter-otlp-1.30.0[${PYTHON_USEDEP}]
	<dev-python/opentelemetry-exporter-otlp-2[${PYTHON_USEDEP}]
	>=dev-python/opentelemetry-instrumentation-fastapi-0.64_beta0[${PYTHON_USEDEP}]
	>=dev-python/opentelemetry-instrumentation-requests-0.64_beta0[${PYTHON_USEDEP}]
	>=dev-python/opentelemetry-instrumentation-urllib3-0.64_beta0[${PYTHON_USEDEP}]
	>=dev-python/prometheus-client-0.20.0[${PYTHON_USEDEP}]
	<dev-python/prometheus-client-1[${PYTHON_USEDEP}]
	dev-python/aiofiles[${PYTHON_USEDEP}]
	>=dev-python/pip-26.0.0[${PYTHON_USEDEP}]
	<dev-python/pip-27[${PYTHON_USEDEP}]
	>=dev-python/setuptools-80.0.0[${PYTHON_USEDEP}]
	>=dev-python/nanoid-2.0.0[${PYTHON_USEDEP}]
	<dev-python/nanoid-3[${PYTHON_USEDEP}]
	>=dev-python/filelock-3.20.1[${PYTHON_USEDEP}]
	<dev-python/filelock-4[${PYTHON_USEDEP}]
	>=dev-python/grandalf-0.8[${PYTHON_USEDEP}]
	<dev-python/grandalf-1[${PYTHON_USEDEP}]
	>=dev-python/spider-client-0.0.27[${PYTHON_USEDEP}]
	<dev-python/spider-client-1[${PYTHON_USEDEP}]
	~dev-python/clickhouse-connect-0.7.19[${PYTHON_USEDEP}]
	>=dev-python/assemblyai-0.33.0[${PYTHON_USEDEP}]
	<dev-python/assemblyai-1[${PYTHON_USEDEP}]
	>=dev-python/fastapi-pagination-0.13.1[${PYTHON_USEDEP}]
	<dev-python/fastapi-pagination-1[${PYTHON_USEDEP}]
	>=dev-python/defusedxml-0.7.1[${PYTHON_USEDEP}]
	<dev-python/defusedxml-1[${PYTHON_USEDEP}]
	>=dev-python/pypdf-6.10.0[${PYTHON_USEDEP}]
	<dev-python/pypdf-7[${PYTHON_USEDEP}]
	>=dev-python/validators-0.34.0[${PYTHON_USEDEP}]
	<dev-python/validators-1[${PYTHON_USEDEP}]
	>=dev-python/networkx-3.4.2[${PYTHON_USEDEP}]
	<dev-python/networkx-4[${PYTHON_USEDEP}]
	>=dev-python/json-repair-0.30.3[${PYTHON_USEDEP}]
	<dev-python/json-repair-1[${PYTHON_USEDEP}]
	>=dev-python/mcp-1.17.0[${PYTHON_USEDEP}]
	<dev-python/mcp-2[${PYTHON_USEDEP}]
	>=dev-python/aiosqlite-0.20.0[${PYTHON_USEDEP}]
	<dev-python/aiosqlite-1[${PYTHON_USEDEP}]
	>=dev-python/greenlet-3.1.1[${PYTHON_USEDEP}]
	<dev-python/greenlet-4[${PYTHON_USEDEP}]
	>=dev-python/jsonquerylang-1.1.1[${PYTHON_USEDEP}]
	<dev-python/jsonquerylang-2[${PYTHON_USEDEP}]
	>=dev-python/sqlalchemy-2.0.38[${PYTHON_USEDEP}]
	<dev-python/sqlalchemy-3[${PYTHON_USEDEP}]
	>=dev-python/elevenlabs-1.52.0[${PYTHON_USEDEP}]
	<dev-python/elevenlabs-2[${PYTHON_USEDEP}]
	>=dev-python/scipy-1.15.2[${PYTHON_USEDEP}]
	<dev-python/scipy-2[${PYTHON_USEDEP}]
	>=dev-python/trustcall-0.0.38[${PYTHON_USEDEP}]
	<dev-python/trustcall-1[${PYTHON_USEDEP}]
	>=dev-python/langchain-chroma-0.2.6[${PYTHON_USEDEP}]
	<dev-python/langchain-chroma-0.3[${PYTHON_USEDEP}]
	>=dev-python/jaraco-context-6.1.0[${PYTHON_USEDEP}]
	>=dev-python/wheel-0.46.2[${PYTHON_USEDEP}]
	<dev-python/wheel-1[${PYTHON_USEDEP}]
	>=sci-libs/onnxruntime-1.26[python,${PYTHON_USEDEP}]
	>=dev-python/dynaconf-3.2.13[${PYTHON_USEDEP}]
	<dev-python/dynaconf-4[${PYTHON_USEDEP}]
	>=dev-python/pyasn1-0.6.3[${PYTHON_USEDEP}]
	<dev-python/pyasn1-0.7[${PYTHON_USEDEP}]
	>dev-python/langgraph-checkpoint-4.0.0-r0[${PYTHON_USEDEP}]
	<dev-python/langgraph-checkpoint-5[${PYTHON_USEDEP}]
	>=sci-ml/transformers-5.3.0
	openai? (
		>=dev-python/langchain-openai-1.1.6[${PYTHON_USEDEP}]
		>=dev-python/openai-1.68.2[${PYTHON_USEDEP}]
		<dev-python/openai-3[${PYTHON_USEDEP}]
	)
	anthropic? (
		>=dev-python/langchain-anthropic-1.4.6[${PYTHON_USEDEP}]
		<dev-python/langchain-anthropic-1.5[${PYTHON_USEDEP}]
	)
	ollama? (
		>=dev-python/langchain-ollama-0.3.10[${PYTHON_USEDEP}]
	)
	google-genai? (
		>=dev-python/langchain-google-genai-4.1.2[${PYTHON_USEDEP}]
	)
	weaviate? (
		>=dev-python/langchain-weaviate-0.0.6[${PYTHON_USEDEP}]
	)
"

RESTRICT="test"

src_unpack() {
	:
}

python_compile() {
	distutils_wheel_install "${BUILD_DIR}/install" "${DISTDIR}/${WHEEL_FILENAME}"
}
