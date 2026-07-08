# frozen_string_literal: true

require 'logger'
require 'thor'

module R2
  # R2 gem CLI.
  #
  # Command-line interface that delegates storage operations
  # to R2::Storage.
  class CLI < Thor
    class << self
      # Storage instance injected externally (e.g., bin/r2).
      # It is required for CLI execution.
      attr_accessor :storage
    end

    # Failures should terminate the process with a non-zero exit code.
    def self.exit_on_failure?
      true
    end

    # Default bucket used in operations.
    class_option :bucket,
                 aliases: '-b',
                 default: 'main',
                 desc: 'R2 bucket name'

    # Enables verbose logging (INFO level) for the underlying operations.
    class_option :verbose,
                 type: :boolean,
                 aliases: '-v',
                 default: false,
                 desc: 'Enable verbose logging'

    # Uploads a file to the configured bucket.
    #
    # Reads the entire file into memory before uploading.
    #
    # @param path [String] local file path
    desc 'upload PATH', 'Upload a file to R2'
    def upload(path)
      apply_log_level

      bucket = options.fetch(:bucket)
      logger&.info("uploading #{path} to bucket #{bucket}")

      result = storage.upload(
        key: File.basename(path),
        bucket: bucket,
        body: read_file(path),
      )

      logger&.info("uploaded #{result[:key]}")
      say("[R2] upload -> #{result[:key]}")
    end

    private

    # Adjusts the logger verbosity based on the --verbose flag.
    def apply_log_level
      return unless logger

      logger.level = options[:verbose] ? Logger::INFO : Logger::ERROR
    end

    # Reads a local file, raising a friendly R2::FileError on common problems.
    #
    # @raise [R2::FileError] when the path is missing, not a file or unreadable
    def read_file(path)
      raise R2::FileError, "file not found: #{path}" unless File.exist?(path)
      raise R2::FileError, "not a file: #{path}" unless File.file?(path)
      raise R2::FileError, "file not readable: #{path}" unless File.readable?(path)

      File.binread(path)
    end

    # Access to the storage instance injected into the class.
    def storage
      self.class.storage
    end

    # Logger owned by the injected storage, if any.
    def logger
      storage.logger
    end
  end
end
