#!/usr/bin/env rake
require 'bundler'

require 'rake/clean'
require 'rake/testtask'

include Rake::DSL

Bundler::GemHelper.install_tasks

Rake::TestTask.new do |t|
  t.libs << "lib" << 'spec/support'
  t.test_files = FileList['spec/**/*_spec.rb']
  t.verbose = false
  t.warning = false # pry-rescue has a lot of warnings
end

task :default => [:test]
