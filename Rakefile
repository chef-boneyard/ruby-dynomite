# -*- ruby -*-

require 'rubygems'
require 'rake/gempackagetask'
require 'rubygems/specification'
require 'date'
require 'spec/rake/spectask'
require 'cucumber/rake/task'
require 'hoe'

GEM = "dynomite"
GEM_VERSION = "0.5"

Hoe.new('dynomite', GEM_VERSION) do |p|
  # p.rubyforge_name = 'dynomite_clientx' # if different than lowercase project name
  p.developer('Christopher Brown (skeptomai)', 'cb@opscode.com')
end

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

desc "install the gem locally"
task :install => [:package] do
  sh %{sudo gem install pkg/#{GEM}-#{GEM_VERSION}}
end

# vim: syntax=Ruby
