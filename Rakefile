# frozen_string_literal: true

require 'rake/testtask'

namespace :test do
  desc 'Run all tests'
  Rake::TestTask.new(:all) do |t|
    t.libs << 'test'
    t.pattern = 'test/**/*_test.rb'
    t.verbose = false
  end

  desc 'Run integration tests'
  Rake::TestTask.new(:integration) do |t|
    t.libs << 'test'
    t.pattern = 'test/integration/**/*_test.rb'
    t.verbose = false
  end

  namespace :e2e do
    desc 'Run all E2E tests'
    Rake::TestTask.new(:all) do |t|
      t.libs << 'test'
      t.pattern = 'test/e2e/**/*_test.rb'
      t.verbose = false
    end

    desc 'Run E2E happy path tests'
    Rake::TestTask.new(:happy_path) do |t|
      t.libs << 'test'
      t.pattern = 'test/e2e/cli_happy_path_test.rb'
      t.verbose = false
    end

    desc 'Run E2E validation tests'
    Rake::TestTask.new(:validation) do |t|
      t.libs << 'test'
      t.pattern = 'test/e2e/cli_validation_test.rb'
      t.verbose = false
    end

    desc 'Run E2E error handling tests'
    Rake::TestTask.new(:error_handling) do |t|
      t.libs << 'test'
      t.pattern = 'test/e2e/cli_error_handling_test.rb'
      t.verbose = false
    end
  end
end

desc 'Run full test suite'
task default: 'test:all'
