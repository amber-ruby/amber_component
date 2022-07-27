# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rake/testtask'

::Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.libs << 'test/fixtures'
  # ignore tests of rails apps
  t.test_files = ::FileList['test/**/*_test.rb'] - ::FileList['test/dummy/**/*_test.rb']
end

require 'rubocop/rake_task'

::RuboCop::RakeTask.new

task default: %i[test rubocop]
