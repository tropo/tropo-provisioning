require 'bundler'
Bundler::GemHelper.install_tasks

task :default => [:test]

require 'rspec/core/rake_task'
require 'rake/rdoctask'
require 'tropo-provisioning/version'


RSpec::Core::RakeTask.new(:test) do |spec|
    spec.skip_bundler = true
    spec.pattern = ['spec/*_spec.rb']
    spec.rspec_opts = '--color --format doc'
end


RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.pattern = 'spec/*_spec.rb'
  spec.rcov = true
end

RDoc::Task.new do |rdoc|

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "tropo-provisioning #{TropoProvisioning::VERSION}"
  rdoc.rdoc_files.include('LICENSE')
  rdoc.options << '-c' << 'utf-8'
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
