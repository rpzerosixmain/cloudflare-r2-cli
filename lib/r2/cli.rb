# frozen_string_literal: true

require 'thor'
require 'marcel'

module R2
  # R2 gem CLI.
  #
  # Command-line interface that delegates storage operations
  # to R2::Storage.
  class CLI < Thor
    # Files at or above this size are uploaded with a progress bar.
    PROGRESS_THRESHOLD = 5 * 1024 * 1024

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

    # Uploads a file to the configured bucket.
    #
    # Streams the file instead of loading it fully into memory.
    #
    # @param path [String] local file path
    desc 'upload PATH', 'Upload a file to R2'
    def upload(path)
      raise Error, "file not found: #{path}" unless File.file?(path)

      File.open(path, 'rb') do |file|
        result = storage.upload(
          key: File.basename(path),
          bucket: options.fetch(:bucket),
          body: body_for(file, File.size(path)),
          content_type: content_type_for(path),
        )

        say("[R2] upload -> #{result[:key]}")
      end
    end

    private

    # Wraps the file in a progress bar only when it is large enough.
    def body_for(file, size)
      return file if size < PROGRESS_THRESHOLD

      ProgressIO.new(file, total: size)
    end

    # Detects the object MIME type from the file name.
    def content_type_for(path)
      Marcel::MimeType.for(name: File.basename(path))
    end

    # Access to the storage instance injected into the class.
    def storage
      self.class.storage
    end
  end
end
