# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=hatchling

inherit distutils-r1 pypi

DESCRIPTION="A tool to determine the content type of a file with deep learning"
HOMEPAGE="
	https://github.com/google/magika
	https://pypi.org/project/magika/
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

# Upstream ships a small (~3MB) pre-trained ONNX model as package data
# (src/magika/models/standard_v3_3/model.onnx) directly in the sdist --
# there is no build-time or run-time model download.
#
# Real dependencies are version-gated by python_version upstream; every
# gate collapses to a single floor across this ebuild's PYTHON_COMPAT
# (all >=3.12):
#   click>=8.1.7
#   numpy>=1.26; python_version>='3.12' and <'3.13'
#   numpy>=2.1.0; python_version>='3.13'                 -- 2.1.0 also
#     satisfies the 3.12 floor, so a single >=2.1.0 covers every target.
#   onnxruntime>=1.17.0; python_version>'3.9'             -- the <1.20.0
#     and sys_platform=='win32' gates are irrelevant here.
#   python-dotenv>=1.0.1
RDEPEND="
	>=dev-python/click-8.1.7[${PYTHON_USEDEP}]
	>=dev-python/numpy-2.1.0[${PYTHON_USEDEP}]
	>=dev-python/python-dotenv-1.0.1[${PYTHON_USEDEP}]
	>=sci-libs/onnxruntime-1.17.0[python,${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"

RESTRICT="test"
