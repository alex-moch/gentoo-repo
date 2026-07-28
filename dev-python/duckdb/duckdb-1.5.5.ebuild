# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# Upstream's pyproject.toml declares build-backend =
# "duckdb_packaging.build_backend" (backend-path = ["./"]) -- a thin
# in-tree wrapper around scikit-build-core that pins the vendored DuckDB
# submodule's version into a CMake define. It is not one of the eclass's
# recognized backend keys, so this has to be "standalone" rather than
# "scikit-build-core"; BDEPEND is therefore listed by hand to match
# pyproject.toml's [build-system].requires exactly.
DISTUTILS_EXT=1
DISTUTILS_USE_PEP517=standalone
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Python client library for DuckDB, an in-process analytical SQL database"
HOMEPAGE="
	https://duckdb.org
	https://github.com/duckdb/duckdb-python
	https://pypi.org/project/duckdb/
"

# Same MIT declaration as dev-db/duckdb for the same vendored source tree
# (external/duckdb/, ~5900 files: the DuckDB C++ engine plus its own
# third_party/ bundle -- re2, utf8proc, fmt, zstd, snappy, a vendored ICU
# copy, etc.) -- not independently re-audited here.
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

# Fully self-contained: builds and statically links its own copy of the
# DuckDB C++ engine (DUCKDB_STATIC_BUILD) plus every third-party library
# DuckDB itself vendors (including ICU -- WITH_INTERNAL_ICU), so there is
# no RDEPEND on dev-db/duckdb or any other C++ library.
BDEPEND="
	>=dev-build/cmake-3.29.0
	app-alternatives/ninja
	>=dev-python/pybind11-2.6.0[${PYTHON_USEDEP}]
	>=dev-python/scikit-build-core-0.11.4[${PYTHON_USEDEP}]
	>=dev-python/setuptools-scm-8[${PYTHON_USEDEP}]
"

RESTRICT="test"

# Not a pure-C-extension rebuild concern, but worth recording for whoever
# touches this next: this compiles the full DuckDB C++ engine (unity
# build enabled by default) from source on every merge. Expect a long,
# memory-hungry build -- the same cost dev-db/duckdb already pays, just
# duplicated here since duckdb-python has no supported path to link
# against a system libduckdb (verified against upstream's
# cmake/duckdb_loader.cmake: it unconditionally add_subdirectory()s a
# bundled external/duckdb checkout and links duckdb_static, with no
# find_package(DuckDB)/pkg-config fallback).
