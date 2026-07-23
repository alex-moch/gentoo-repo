# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

USE_RUBY="ruby40"

RUBY_FAKEGEM_NAME="winrm-fs"
RUBY_FAKEGEM_RECIPE_TEST="none"

RUBY_FAKEGEM_EXTRADOC="README.md"

inherit ruby-fakegem

DESCRIPTION="File system operations (upload/download) for WinRM"
HOMEPAGE="https://github.com/WinRb/winrm-fs"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

ruby_add_depend "
	>=dev-ruby/erubi-1.8
	>=dev-ruby/logging-1.6.1
	<dev-ruby/logging-3.0
	>=dev-ruby/rubyzip-2.0
	>=dev-ruby/winrm-2.0
"

# The gem's own packaged metadata pins `rubyzip ~> 2.0`, which RubyGems
# enforces strictly at `require` time regardless of the Portage-level
# floor above -- only rubyzip-3.2.2 exists in the tree. Its own 3.0
# changelog shows nothing touching the Zip::OutputStream/Zip::Entry/
# Zip::DOSTime API winrm-fs actually uses, so relax the pin in the
# unpacked gem metadata (read by each_fakegem_install) before it's
# turned into the installed .gemspec.
each_ruby_prepare() {
	local metadata="${WORKDIR}/${_ruby_implementation}/metadata"
	chmod u+w "${metadata}" || die
	${RUBY} -ryaml -e "
		spec = Gem::Specification.from_yaml(File.read('${metadata}', encoding: 'UTF-8'))
		spec.dependencies.reject! { |dep| dep.name == 'rubyzip' }
		spec.dependencies << Gem::Dependency.new('rubyzip', '>= 2.0')
		File.write('${metadata}', spec.to_yaml)
	" || die "Failed to relax the rubyzip version constraint"
}
