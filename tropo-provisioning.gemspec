# -*- encoding: utf-8 -*-

$:.unshift File.join(File.dirname(__FILE__), 'lib')

require 'tropo-provisioning/version'

Gem::Specification.new do |s|
  s.name = "tropo-provisioning"
  s.version = TropoProvisioning::VERSION

  s.authors = ["Jason Goecke", "John Dyer", "Juan de Bravo"]
  s.email = ["jsgoecke@voxeo.com", "johntdyer@gmail.com", "juandebravo@gmail.com"]

  s.date = %q{2013-01-04}
  s.description = %q{Library for interacting with the Tropo Provisioning API}
  s.summary = %q{Library for interacting with the Tropo Provisioning API}

  s.rubyforge_project = "tropo-provisioning"

  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- {examples,test,spec,features}/*`.split("\n")

  s.homepage = %q{http://github.com/tropo/tropo-provisioning}
  s.require_paths = ["lib"]

  s.add_runtime_dependency("i18n", "= 0.6.1")
  s.add_runtime_dependency("activesupport","= 3.2.13")
  s.add_runtime_dependency("hashie", "= 2.0.3")
  s.add_runtime_dependency("json", "= 1.8.0") if RUBY_VERSION =~ /1.8/

  s.add_development_dependency("rspec", "= 2.13.0")
  s.add_development_dependency("fakeweb", "= 1.3.0")
  s.add_development_dependency("yard", "= 0.8.1")
  s.add_development_dependency("rdoc", "= 3.12")
  s.add_development_dependency("rake", "= 0.9.2.2")

end

