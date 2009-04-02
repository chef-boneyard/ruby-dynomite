# -*- ruby -*-

require 'rubygems'
require 'rake/gempackagetask'
require 'rubygems/specification'
require 'date'
require 'spec/rake/spectask'
require 'cucumber/rake/task'

GEM = "dynomite"
GEM_VERSION = "0.0.1"
AUTHOR = "Opscode, Inc."
EMAIL = "legal@opscode.com"
HOMEPAGE = "http://www.opscode.com"
SUMMARY = "Drives Cliff Moon's 'dynomite' - an Erlang implementation of Amazon's Dynamo"

spec = Gem::Specification.new do |s|
  s.name = GEM
  s.version = GEM_VERSION
  s.platform = Gem::Platform::RUBY
  s.has_rdoc = false
  # s.extra_rdoc_files = ['TODO']
  s.summary = SUMMARY
  s.description = s.summary
  s.author = AUTHOR
  s.email = EMAIL
  s.homepage = HOMEPAGE
  
  # Uncomment this to add a dependency
  # s.add_dependency "foo"
  
  s.require_path = 'lib'
  s.autorequire = GEM
  s.files = %w(Rakefile TODO) + Dir.glob("{lib,spec}/**/*")
  s.executables = "dynoctl"
end

task :default => :spec

Cucumber::Rake::Task.new(:features) do |t|
  #  t.cucumber_opts = "--format progress"
#  t.cucumber_opts = "--format profile features"
  t.step_pattern = ["features/step_definitions/**/*.rb"]
  t.feature_pattern = "features/**/*.feature"
end

desc "Run specs"
Spec::Rake::SpecTask.new do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
  t.spec_opts = %w(-fs --color)
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
end

desc "create a gemspec file"
task :make_spec do
  File.open("#{GEM}.gemspec", "w") do |file|
    file.puts spec.to_ruby
  end
end

desc "remove build files"
task :clean do
  sh %Q{ rm -f pkg/*.gem }
end

desc "install the gem locally"
task :install => [:package] do
  sh %{sudo gem install pkg/#{GEM}-#{GEM_VERSION}}
end

# vim: syntax=Ruby
