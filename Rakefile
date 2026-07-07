# frozen_string_literal: true

require 'rake/testtask'
require 'rbconfig'
require 'fileutils'

# Directory where debug sample files are written (gitignored).
DEBUG_DIR = ENV.fetch('R2_DEBUG_DIR', 'tmp/debug')

# Supported debug file sizes, mapped to their size in mebibytes.
DEBUG_SIZES = { '1mb' => 1, '5mb' => 5, '10mb' => 10 }.freeze

MEBIBYTE = 1024 * 1024

# Absolute-ish path for a debug sample file of the given label.
def debug_file_path(label)
  File.join(DEBUG_DIR, "sample_#{label}.bin")
end

# Writes a file of `megabytes` MiB, filled with zero bytes, and returns its path.
def generate_debug_file(label, megabytes)
  FileUtils.mkdir_p(DEBUG_DIR)

  path = debug_file_path(label)
  chunk = "\0" * MEBIBYTE
  File.open(path, 'wb') { |file| megabytes.times { file.write(chunk) } }

  puts "[debug] generated #{path} (#{megabytes} MiB)"
  path
end

# Resolves a size label to its MiB value or aborts with a helpful message.
def debug_size!(label)
  DEBUG_SIZES.fetch(label) do
    abort("[debug] unknown size #{label.inspect}; use one of: #{DEBUG_SIZES.keys.join(', ')}")
  end
end

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

namespace :debug do
  desc "Generate all debug sample files (#{DEBUG_SIZES.keys.join(', ')}) in #{DEBUG_DIR}"
  task :files do
    DEBUG_SIZES.each { |label, megabytes| generate_debug_file(label, megabytes) }
  end

  desc 'Generate a single debug file, e.g. rake "debug:file[10mb]"'
  task :file, [:size] do |_task, args|
    label = args.fetch(:size, DEBUG_SIZES.keys.first)
    generate_debug_file(label, debug_size!(label))
  end

  desc 'Generate a file and upload it via the CLI, e.g. rake "debug:upload[10mb]"'
  task :upload, [:size] do |_task, args|
    label = args.fetch(:size, DEBUG_SIZES.keys.first)
    path = generate_debug_file(label, debug_size!(label))
    sh RbConfig.ruby, 'exe/r2', 'upload', path
  end

  desc "Remove generated debug files (#{DEBUG_DIR})"
  task :clean do
    FileUtils.rm_rf(DEBUG_DIR)
    puts "[debug] removed #{DEBUG_DIR}"
  end
end

desc 'Run full test suite'
task default: 'test:all'
