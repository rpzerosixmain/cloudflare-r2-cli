# frozen_string_literal: true

require 'rake/testtask'

namespace :test do
  desc 'Run all tests'
  Rake::TestTask.new(:all) do |t|
    t.libs << 'test'
    t.pattern = 'test/**/*_test.rb'
    t.verbose = false
  end

  desc 'Run unit tests'
  Rake::TestTask.new(:unit) do |t|
    t.libs << 'test'
    t.pattern = 'test/unit/**/*_test.rb'
    t.verbose = false
  end

  desc 'Run E2E tests'
  Rake::TestTask.new(:e2e) do |t|
    t.libs << 'test'
    t.pattern = 'test/e2e/**/*_test.rb'
    t.verbose = false
  end
end
