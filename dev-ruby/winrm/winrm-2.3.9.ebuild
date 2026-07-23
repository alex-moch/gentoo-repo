# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

USE_RUBY="ruby40"

RUBY_FAKEGEM_NAME="winrm"
RUBY_FAKEGEM_RECIPE_TEST="none"

RUBY_FAKEGEM_EXTRADOC="README.md"

inherit ruby-fakegem

DESCRIPTION="Ruby library for Windows Remote Management"
HOMEPAGE="https://github.com/WinRb/WinRM"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

ruby_add_depend "
	>=dev-ruby/builder-2.1.2
	>=dev-ruby/erubi-1.8
	>=dev-ruby/gssapi-1.2
	>=dev-ruby/gyoku-1.0
	>=dev-ruby/httpclient-2.2.0.2
	>=dev-ruby/logging-1.6.1
	<dev-ruby/logging-3.0
	>=dev-ruby/nori-2.7.1
	>=dev-ruby/rexml-3.0
	>=dev-ruby/rubyntlm-0.6.3
"
