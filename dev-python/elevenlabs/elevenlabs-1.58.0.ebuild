# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=poetry-core

inherit distutils-r1 pypi

DESCRIPTION="The official Python SDK for ElevenLabs"
HOMEPAGE="
	https://github.com/elevenlabs/elevenlabs-python
	https://pypi.org/project/elevenlabs/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RESTRICT="test"

# langflow-base pins elevenlabs<2.0.0,>=1.52.0 (for python_version != "3.12";
# this tree's python3.14 target falls under that branch) -- PyPI's latest
# is 2.59.0, well past the real ceiling. Don't bump past 1.x.
#
# Upstream also lists pydantic-core>=2.18.2, but Gentoo does not carry
# it as a standalone package: dev-python/pydantic vendors a matching
# pydantic-core build and blocks a separate dev-python/pydantic-core
# install, so the dep below on pydantic already provides it.
RDEPEND="
	>=dev-python/httpx-0.21.2[${PYTHON_USEDEP}]
	>=dev-python/pydantic-1.9.2[${PYTHON_USEDEP}]
	>=dev-python/requests-2.20[${PYTHON_USEDEP}]
	>=dev-python/typing-extensions-4.0.0[${PYTHON_USEDEP}]
	>=dev-python/websockets-13.0[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"
