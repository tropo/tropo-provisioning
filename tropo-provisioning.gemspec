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

  s.add_development_dependency("rspec")
  s.add_development_dependency("fakeweb")
  s.add_development_dependency("yard")
  s.add_development_dependency("rdoc")
  s.add_development_dependency("rake")

  s.add_runtime_dependency("hashie", ">= 0.2.1")
  s.add_runtime_dependency("activesupport")
  s.add_runtime_dependency("i18n")
  s.add_runtime_dependency("json") if RUBY_VERSION =~ /1.8/
end

