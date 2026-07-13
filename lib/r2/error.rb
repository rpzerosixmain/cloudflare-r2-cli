# frozen_string_literal: true

module R2
  # Base error for every failure raised by the gem.
  class Error < StandardError; end

  # Raised when required configuration (e.g. environment variables) is missing.
  class ConfigurationError < Error; end

  # Raised when command arguments are invalid.
  class UsageError < Error; end

  # Raised when a local file cannot be read for an operation.
  class FileError < Error; end

  # Raised when the storage backend (R2/S3) reports a failure.
  class StorageError < Error; end
end
