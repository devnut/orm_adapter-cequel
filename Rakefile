require "bundler/gem_tasks"
require "rspec/core/rake_task"
require 'rubocop/rake_task'
require File.expand_path('../lib/orm_adapter/cequel/version', __FILE__)

RSpec::Core::RakeTask.new(:spec)

task :default => :release
task :release => [
  :rubocop,
  :"test:concise",
  :build,
  :tag,
  :update_stable,
  :push,
  :cleanup
]

desc 'Build gem'
task :build do
  system 'gem build orm_adapter-cequel.gemspec'
end

desc 'Create git release tag'
task :tag do
  system "git tag -a -m 'Version #{OrmAdapterCequel::VERSION}' #{OrmAdapterCequel::VERSION}"
  system "git push origin #{OrmAdapterCequel::VERSION}:#{OrmAdapterCequel::VERSION}"
end

desc 'Update stable branch on GitHub'
task :update_stable do
  if OrmAdapterCequel::VERSION =~ /^(\d+\.)+\d+$/ # Don't push for prerelease
    system "git push -f origin HEAD:stable"
  end
end

desc 'Push gem to repository'
task :push do
  system "gem push orm_adapter-cequel-#{OrmAdapterCequel::VERSION}.gem"
end

task 'Remove packaged gems'
task :cleanup do
  system "rm -v *.gem"
end

desc 'Check style with Rubocop'
Rubocop::RakeTask.new(:rubocop) do |task|
  task.patterns = ['lib']
  task.formatters = ['files']
  task.fail_on_error = true
end

desc 'Run the specs'
RSpec::Core::RakeTask.new(:test) do |t|
  t.pattern = './spec/examples/**/*_spec.rb'
  t.rspec_opts = '--fail-fast'
  t.fail_on_error = true
end

namespace :test do
  desc 'Run the specs with progress formatter'
  RSpec::Core::RakeTask.new(:concise) do |t|
    t.pattern = './spec/examples/**/*_spec.rb'
    t.rspec_opts = '--fail-fast --format=progress'
    t.fail_on_error = true
  end
end
