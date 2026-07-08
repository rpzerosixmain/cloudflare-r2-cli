# frozen_string_literal: true

require 'logger'
require 'marcel'
require 'thor'

module R2
  # R2 gem CLI.
  #
  # Command-line interface that delegates storage operations
  # to R2::Storage.
  class CLI < Thor
    # Failures should terminate the process with a non-zero exit code.
    def self.exit_on_failure?
      true
    end

    # Injects dependencies through Thor's config, avoiding global mutable state.
    #
    # @param config [Hash] may carry :storage and :logger instances
    def initialize(args = [], local_options = {}, config = {})
      super
      @storage = config[:storage]
      @logger = config[:logger] || NullLogger.new
    end

    # Default bucket used in operations.
    class_option :bucket,
                 aliases: '-b',
                 default: 'main',
                 desc: 'R2 bucket name'

    # Full object key to store the file under (overrides --prefix).
    class_option :key,
                 aliases: '-k',
                 desc: 'Destination object key (defaults to the file name)'

    # Prefix ("folder") prepended to the file name when no --key is given.
    class_option :prefix,
                 aliases: '-p',
                 desc: 'Destination key prefix, e.g. "photos"'

    # Enables verbose logging (INFO level) for the underlying operations.
    class_option :verbose,
                 type: :boolean,
                 aliases: '-v',
                 default: false,
                 desc: 'Enable verbose logging'

    # Uploads a file to the configured bucket.
    #
    # Streams the file to storage instead of buffering it in memory.
    #
    # @param path [String] local file path
    desc 'upload PATH', 'Upload a file to R2'
    def upload(path)
      apply_log_level
      ensure_readable!(path)

      key = object_key(path)
      logger.info("uploading #{path} to #{bucket}/#{key}")

      result = File.open(path, 'rb') do |io|
        storage.upload(
          bucket: bucket,
          key: key,
          body: io,
          content_type: content_type_for(path),
        )
      end

      logger.info("uploaded #{result[:key]}")
      say("[R2] upload -> #{result[:key]}")
    end

    private

    attr_reader :storage, :logger

    # Target bucket for the current invocation.
    def bucket
      options.fetch(:bucket)
    end

    # Adjusts the logger verbosity based on the --verbose flag.
    def apply_log_level
      logger.level = options[:verbose] ? Logger::INFO : Logger::ERROR
    end

    # Resolves the destination object key from --key/--prefix or the file name.
    def object_key(path)
      return options[:key] if options[:key]

      prefix = options[:prefix].to_s.strip.delete_suffix('/')
      base = File.basename(path)

      prefix.empty? ? base : "#{prefix}/#{base}"
    end

    # Detects the MIME type for the file from its name.
    def content_type_for(path)
      Marcel::MimeType.for(name: File.basename(path))
    end

    # Validates the local file, raising a friendly R2::FileError on problems.
    #
    # @raise [R2::FileError] when the path is missing, not a file or unreadable
    def ensure_readable!(path)
      raise R2::FileError, "file not found: #{path}" unless File.exist?(path)
      raise R2::FileError, "not a file: #{path}" unless File.file?(path)
      raise R2::FileError, "file not readable: #{path}" unless File.readable?(path)
    end
  end
end
