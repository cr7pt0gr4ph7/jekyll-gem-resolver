# frozen_string_literal: true
require 'rake'
require 'rake/testtask'
require 'bundler/gem_tasks'

task(:default, [:test])

desc('run test suite')
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib' << 'test'
  t.test_files = FileList['test/{integration,unit}/**/*_test.rb']
  t.verbose    = false
end
