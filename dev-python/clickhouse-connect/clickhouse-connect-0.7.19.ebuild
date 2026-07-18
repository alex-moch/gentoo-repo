# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=setuptools
# The real 0.7.19 sdist upload uses a literal hyphen (clickhouse-connect-
# 0.7.19.tar.gz); the eclass's default underscore-normalized guess
# (clickhouse_connect-0.7.19.tar.gz) 404s against files.pythonhosted.org
# for this specific old release.
PYPI_NO_NORMALIZE=1

inherit distutils-r1 pypi

DESCRIPTION="ClickHouse Database Core Driver for Python, Pandas, and Superset"
HOMEPAGE="
	https://github.com/ClickHouse/clickhouse-connect
	https://pypi.org/project/clickhouse-connect/
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

RESTRICT="test"

# langflow-base pins clickhouse-connect==0.7.19 exactly. Its RDEPEND is a
# plain unconditional set (no per-python-version zstandard/lz4 split, that
# was added in a later release) matching its real install_requires:
# certifi, urllib3>=1.26, pytz, zstandard, lz4 -- the pyarrow/numpy/orjson/
# pandas/sqlalchemy/tzlocal entries are all `extra ==`-gated and unneeded.
RDEPEND="
	dev-python/certifi[${PYTHON_USEDEP}]
	>=dev-python/urllib3-1.26[${PYTHON_USEDEP}]
	dev-python/pytz[${PYTHON_USEDEP}]
	dev-python/zstandard[${PYTHON_USEDEP}]
	dev-python/lz4[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"
# Upstream's pyproject.toml pins an exact `cython==3.0.10`, unavailable in
# the tree (only 3.2.x exists); setup.py wraps the cythonize() call in a
# try/except and falls back to a pure-Python driver if Cython is missing
# or the build fails, so this is a best-effort accelerator, not a hard
# requirement -- verify with a real build that the C extensions actually
# compile against 3.2.x before trusting the accelerated path.
BDEPEND="
	dev-python/cython[${PYTHON_USEDEP}]
"
