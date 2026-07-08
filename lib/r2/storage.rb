# frozen_string_literal: true

require 'aws-sdk-s3'

module R2
  # Storage responsible for encapsulating S3/R2 operations.
  #
  # Acts as an abstraction layer between the application and the AWS SDK,
  # centralizing storage operations and error translation. Logging is
  # intentionally left to the caller to keep this layer decoupled.
  class Storage
    def initialize(
      access_key_id:,
      secret_access_key:,
      endpoint:,
      region: 'auto',
      s3: nil
    )
      @s3 = s3 || Aws::S3::Client.new(
        access_key_id: access_key_id,
        secret_access_key: secret_access_key,
        endpoint: endpoint,
        region: region,
      )
    end

    # Uploads an object to the storage bucket.
    #
    # @param bucket [String] storage bucket name
    # @param key [String] object key in storage
    # @param body [String, IO] file content (an IO is streamed, not buffered)
    # @param content_type [String, nil] optional MIME type for the object
    # @return [Hash] returns only the key of the stored object
    #
    # @raise [R2::Error] when a storage service error occurs
    def upload(bucket:, key:, body:, content_type: nil)
      handle_errors do
        params = { bucket: bucket, key: key, body: body }
        params[:content_type] = content_type if content_type

        s3.put_object(**params)

        { key: key }
      end
    end

    private

    attr_reader :s3

    # Executes a block with standardized storage error handling.
    #
    # Converts AWS SDK service and networking errors into R2::StorageError,
    # keeping the original error as the exception cause.
    def handle_errors
      yield
    rescue Aws::Errors::ServiceError, Seahorse::Client::NetworkingError => e
      raise R2::StorageError, e.message
    end
  end
end
