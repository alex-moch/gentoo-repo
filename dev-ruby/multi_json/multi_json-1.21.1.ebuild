# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# Bumped 1.19.1 -> 1.21.1 (current upstream latest) and added ruby40 --
# neither the Gentoo tree's existing ebuild nor any version in it declares
# ruby40 support yet, needed by dev-ruby/logging (a evil-winrm dependency).
# 1.21.1's gemspec adds a new concurrent-ruby dependency, but it's gated
# behind `if RUBY_ENGINE == "jruby"` -- irrelevant on the standard MRI
# Ruby this overlay uses.
USE_RUBY="ruby32 ruby33 ruby34 ruby40"

RUBY_FAKEGEM_BINDIR=""
RUBY_FAKEGEM_TASK_DOC="yard"

RUBY_FAKEGEM_DOCDIR="rdoc"
RUBY_FAKEGEM_EXTRADOC="README.md"

RUBY_FAKEGEM_GEMSPEC="multi_json.gemspec"

RUBY_FAKEGEM_RECIPE_TEST="none"

inherit ruby-fakegem

DESCRIPTION="A gem to provide swappable JSON backends"
HOMEPAGE="https://github.com/sferik/multi_json"
SRC_URI="https://github.com/sferik/multi_json/archive/v${PV}.tar.gz -> ${P}.tar.gz"
LICENSE="MIT"

SLOT="0"
KEYWORDS="~amd64"

ruby_add_rdepend "|| ( >=dev-ruby/json-1.4:* >=dev-ruby/yajl-ruby-1.0 )"
