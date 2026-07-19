# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

# Pennyw0rth's fork never bumps __info__.py's __version__ past "0.1.5"
# despite tagging real releases (v1.0.6 et al) -- the git tags don't
# track the distributed package's own version scheme. Pinned to the
# v1.0.6 tag's commit for 8 real bugfix commits (RPC port binding,
# byte/str handling, large-data-transfer fix) since the Pentoo ebuild
# this was forked from pinned a commit from 2025-03-02, well before all
# of them landed.
HASH_COMMIT="a8fea2c163bf665dc6a8e35bb50e7baf81e2c6ed"

DESCRIPTION="A library to simulate NFS client"
HOMEPAGE="https://github.com/Pennyw0rth/NfsClient"
SRC_URI="https://github.com/Pennyw0rth/NfsClient/archive/${HASH_COMMIT}.tar.gz -> ${P}.gh.tar.gz"
S="${WORKDIR}/NfsClient-${HASH_COMMIT}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RESTRICT="test"
