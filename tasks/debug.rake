# frozen_string_literal: true

require 'fileutils'
require 'time'

# Directory where generated debug files are stored.
# Can be customized through the R2_DEBUG_DIR environment variable.
DEBUG_DIR = ENV.fetch('R2_DEBUG_DIR', 'tmp/debug')

# Default size of the generated debug file in MiB.
DEFAULT_DEBUG_FILE_SIZE = 10

# Number of bytes in one mebibyte (1024 * 1024).
MEBIBYTE = 1024 * 1024

namespace :debug do
  desc 'Seed a debug file'
  task :seed do
    # Creates the debug directory if it does not exist.
    FileUtils.mkdir_p(DEBUG_DIR)

    # Generates a unique filename using creation date, time and file size.
    timestamp = Time.now.strftime('%Y%m%d_%H%M%S')
    filename = "#{timestamp}_#{DEFAULT_DEBUG_FILE_SIZE}mb.bin"

    path = File.join(DEBUG_DIR, filename)

    # Writes the file in chunks to avoid allocating the entire file in memory.
    chunk = "\0" * MEBIBYTE

    File.open(path, 'wb') do |file|
      DEFAULT_DEBUG_FILE_SIZE.times { file.write(chunk) }
    end

    puts "[debug] seeded #{path} (#{DEFAULT_DEBUG_FILE_SIZE} MiB)"
  end

  desc 'Remove debug files'
  task :clean do
    # Removes all generated debug files.
    FileUtils.rm_rf(DEBUG_DIR)

    puts "[debug] removed #{DEBUG_DIR}"
  end
end
