# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
# Uses PEP 695 generic function syntax (def foo[T](...)), which needs >=3.12.
PYTHON_COMPAT=( python3_{12..15} )

inherit distutils-r1

DESCRIPTION="Cross-platform ZFS replication solution used by TrueNAS"
HOMEPAGE="https://github.com/truenas/zettarepl"

# Upstream has no independent release scheme: the only tags are TrueNAS
# SCALE release tags (e.g. TS-25.10.4), and there is no PyPI package.
if [[ ${PV} == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/truenas/zettarepl.git"
else
	MY_PV="TS-${PV}"
	S="${WORKDIR}/${PN}-${MY_PV}"
	SRC_URI="https://github.com/truenas/${PN}/archive/refs/tags/${MY_PV}.tar.gz -> ${P}.gh.tar.gz"
	KEYWORDS="~amd64"
fi

# Upstream's own setup.py says LICENSE="BSD", but that is stale metadata
# left over from before TrueNAS SCALE's Linux fork relicensed the project;
# the actual LICENSE file (byte-identical to licenses/GPL-3) is GPLv3.
LICENSE="GPL-3"
SLOT="0"

IUSE="lz4 mbuffer pigz plzip"

# app-arch/xz-utils is always used (xz/xzdec) and is part of the @system
# set, so it is not gated behind a USE flag. The other compressors are
# only invoked when a replication task explicitly selects them.
#
# coloredlogs/isodate/pytz are only needed by the TS-25.10.4 tag: master
# has since dropped them (coloredlogs from main.py's log setup, isodate/
# pytz in favour of stdlib datetime/zoneinfo) without a corresponding
# setup.py or PyPI release to pin against, so the live ebuild must not
# depend on them. Re-check this split on every version bump.
RDEPEND="
	dev-python/croniter[${PYTHON_USEDEP}]
	dev-python/jsonschema[${PYTHON_USEDEP}]
	dev-python/paramiko[${PYTHON_USEDEP}]
	dev-python/python-dateutil[${PYTHON_USEDEP}]
	dev-python/pyyaml[${PYTHON_USEDEP}]
	app-arch/xz-utils
	lz4? ( app-arch/lz4 )
	mbuffer? ( sys-block/mbuffer )
	pigz? ( app-arch/pigz )
	plzip? ( app-arch/plzip )
"
if [[ ${PV} != *9999* ]]; then
	RDEPEND+="
		dev-python/coloredlogs[${PYTHON_USEDEP}]
		dev-python/isodate[${PYTHON_USEDEP}]
		dev-python/pytz[${PYTHON_USEDEP}]
	"
fi

# Tests are not wired up: some integration tests need a real ZFS pool and
# a TrueNAS middleware socket to talk to, neither of which exist in a
# portage sandbox.
RESTRICT="test"
