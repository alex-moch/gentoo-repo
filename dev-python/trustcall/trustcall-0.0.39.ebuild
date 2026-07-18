# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=setuptools

inherit distutils-r1 pypi

DESCRIPTION="Tenacious & trustworthy tool calling built on LangGraph"
HOMEPAGE="
	https://github.com/hinthornw/trustcall
	https://pypi.org/project/trustcall/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RESTRICT="test"

RDEPEND="
	>=dev-python/dydantic-0.0.8[${PYTHON_USEDEP}]
	<dev-python/dydantic-1.0.0[${PYTHON_USEDEP}]
	>=dev-python/jsonpatch-1.33[${PYTHON_USEDEP}]
	<dev-python/jsonpatch-2.0[${PYTHON_USEDEP}]
	>=dev-python/langgraph-0.2.25[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"

src_prepare() {
	distutils-r1_src_prepare

	# Upstream's pyproject.toml carries a [tool.setuptools] packaging table
	# but omits [build-system] entirely, so PEP 517 tooling cannot
	# determine a backend. Supply the standard setuptools backend.
	grep -q '^\[build-system\]' pyproject.toml || cat >> pyproject.toml <<-EOF || die
		[build-system]
		requires = ["setuptools>=61.0"]
		build-backend = "setuptools.build_meta"
	EOF
}
