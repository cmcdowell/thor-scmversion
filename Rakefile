#!/usr/bin/env rake
begin
  require 'rspec/core/rake_task'
  require 'cucumber'
  require 'cucumber/rake/task'

  RSpec::Core::RakeTask.new(:spec)

  Cucumber::Rake::Task.new(:features) do |t|
    t.cucumber_opts = "--format pretty --tags ~wip --tags ~@p4"
  end

  task :default => :spec
rescue LoadError
  # no rspec available
end
