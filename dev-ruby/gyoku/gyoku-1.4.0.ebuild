# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

USE_RUBY="ruby40"

RUBY_FAKEGEM_RECIPE_TEST="none"

RUBY_FAKEGEM_EXTRADOC="README.md"

inherit ruby-fakegem

DESCRIPTION="Translates Ruby Hashes to XML"
HOMEPAGE="https://github.com/savonrb/gyoku"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

ruby_add_depend "
	>=dev-ruby/builder-2.1.2
	>=dev-ruby/rexml-3.0
"
