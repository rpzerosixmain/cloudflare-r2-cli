# frozen_string_literal: true

require 'fileutils'
require 'pathname'
require 'time'

# Directory where generated debug files are stored.
# Can be customized through the R2_DEBUG_DIR environment variable.
DEBUG_DIR = ENV.fetch('R2_DEBUG_DIR', 'tmp/debug')

# Default size of the generated debug file in MiB.
DEFAULT_DEBUG_FILE_SIZE = 10

# Number of bytes in one mebibyte (1024 * 1024).
MEBIBYTE = 1024 * 1024

# Glob matching the debug files this task generates.
DEBUG_FILE_GLOB = '*mb.bin'

# Resolves a path through existing symlinks, including nonexistent children.
def canonical_path(path)
  return path.realpath if path.exist? || path.symlink?
  return path.expand_path if path.parent == path

  canonical_path(path.parent).join(path.basename)
end

# Resolves DEBUG_DIR and guarantees it stays inside the project tree.
def resolved_debug_dir
  project_root = Pathname.new(File.expand_path('..', __dir__)).realpath
  target = Pathname.new(DEBUG_DIR)
  target = project_root.join(target) if target.relative?
  target = canonical_path(target)

  unless target != project_root && target.to_s.start_with?("#{project_root}/")
    raise "refusing to use debug dir outside the project: #{DEBUG_DIR}"
  end

  target
end

namespace :debug do
  desc 'Seed a debug file'
  task :seed do
    dir = resolved_debug_dir
    FileUtils.mkdir_p(dir)

    timestamp = Time.now.strftime('%Y%m%d_%H%M%S')
    filename = "#{timestamp}_#{DEFAULT_DEBUG_FILE_SIZE}mb.bin"
    path = dir.join(filename)

    # Writes the file in chunks to avoid allocating the entire file in memory.
    chunk = "\0" * MEBIBYTE
    File.open(path, 'wb') do |file|
      DEFAULT_DEBUG_FILE_SIZE.times { file.write(chunk) }
    end

    puts "[debug] seeded #{path} (#{DEFAULT_DEBUG_FILE_SIZE} MiB)"
  end

  desc 'Remove generated debug files'
  task :clean do
    dir = resolved_debug_dir

    unless dir.directory?
      puts "[debug] nothing to remove at #{dir}"
      next
    end

    # Only removes the debug files this task generates, never arbitrary content.
    removed = Dir.glob(dir.join(DEBUG_FILE_GLOB).to_s).each { |file| FileUtils.rm_f(file) }

    puts "[debug] removed #{removed.length} file(s) from #{dir}"
  end
end
