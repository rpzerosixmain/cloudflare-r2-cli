# frozen_string_literal: true

require 'aws-sdk-s3'

module R2
  # Storage responsible for encapsulating S3/R2 operations.
  #
  # Acts as an abstraction layer between the application and the AWS SDK,
  # centralizing storage operations and error handling.
  class Storage
    attr_accessor :logger

    def initialize(
      access_key_id:,
      secret_access_key:,
      endpoint:,
      region: 'auto',
      s3: nil,
      logger: nil
    )
      @s3 = s3 || Aws::S3::Client.new(
        access_key_id: access_key_id,
        secret_access_key: secret_access_key,
        endpoint: endpoint,
        region: region,
      )

      @logger = logger
    end

    # Uploads an object to the storage bucket.
    #
    # @param bucket [String] storage bucket name
    # @param key [String] object key in storage
    # @param body [String, IO] file content (streamed when an IO is given)
    # @param content_type [String, nil] object MIME type (omitted when nil)
    # @return [Hash] returns only the key of the stored object
    #
    # @raise [R2::Error] when a storage service error occurs
    def upload(bucket:, key:, body:, content_type: nil)
      handle_errors do
        s3.put_object(
          bucket: bucket,
          key: key,
          body: body,
          content_type: content_type,
        )

        { key: key }
      end
    end

    private

    attr_reader :s3

    # Executes a block with standardized storage error handling.
    #
    # Converts AWS SDK errors into R2::Error and logs them if a logger is present.
    def handle_errors
      yield
    rescue Aws::S3::Errors::NoSuchBucket,
           Aws::S3::Errors::NoSuchKey,
           Aws::S3::Errors::AccessDenied,
           Aws::Errors::ServiceError => e

      logger&.error(e.message)
      raise R2::Error, e.message
    end
  end
end
