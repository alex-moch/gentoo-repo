# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

USE_RUBY="ruby40"

RUBY_FAKEGEM_NAME="evil-winrm"
RUBY_FAKEGEM_RECIPE_TEST="none"

# bin/evil-winrm does `require File.expand_path('../evil-winrm.rb', __dir__)`
# -- evil-winrm.rb sits at the gem root rather than under lib/, which
# each_fakegem_install's default bin/lib/sig scan doesn't pick up.
RUBY_FAKEGEM_EXTRAINSTALL="evil-winrm.rb"

inherit ruby-fakegem

DESCRIPTION="The ultimate WinRM shell for hacking/pentesting"
HOMEPAGE="https://github.com/Hackplayers/evil-winrm"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~amd64"

ruby_add_depend "
	>=dev-ruby/benchmark-0.1.0
	>=dev-ruby/csv-2.4.8
	>=dev-ruby/fileutils-1.0
	>=dev-ruby/logger-1.4.3
	>=dev-ruby/stringio-3.0
	>=dev-ruby/syslog-0.3.0
	>=dev-ruby/winrm-2.3.7
	>=dev-ruby/winrm-fs-1.3.2
"
