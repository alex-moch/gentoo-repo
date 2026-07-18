# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )
PYPI_PN="sentry_sdk"

inherit distutils-r1 pypi

DESCRIPTION="Python client for Sentry"
HOMEPAGE="
	https://sentry.io/
	https://github.com/getsentry/sentry-python/
	https://pypi.org/project/sentry-sdk/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RESTRICT="test"

# langflow-base pins sentry-sdk[fastapi,loguru]>=2.5.1,<3.0.0 -- the base
# install is just urllib3/certifi; loguru is added below for the loguru
# extra's floor. fastapi is deliberately NOT added here: the tree's
# dev-python/fastapi-0.139.0 only supports PYTHON_COMPAT=( python3_{14..15} ),
# so a same-PYTHON_USEDEP atom is unsolvable for this ebuild's python3_12/13
# targets (same NonsolvableDeps trap hit and fixed the same way on
# dev-python/opentelemetry-instrumentation-fastapi). fastapi is the
# "instruments"-extra target library, not a real build requirement of
# sentry-sdk itself, and langflow-base already carries its own top-level
# fastapi RDEPEND, so it's covered regardless.
RDEPEND="
	>=dev-python/urllib3-1.26.11[${PYTHON_USEDEP}]
	dev-python/certifi[${PYTHON_USEDEP}]
	>=dev-python/loguru-0.5[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"

DOCS=( README.md )
