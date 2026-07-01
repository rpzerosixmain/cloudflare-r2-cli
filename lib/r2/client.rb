# frozen_string_literal: true

require 'aws-sdk-s3'

module R2
  # Client responsible for encapsulating S3/R2 operations.
  #
  # Acts as an adaptation layer between the application and the AWS SDK,
  # centralizing calls and error handling.
  class Client
    attr_accessor :logger

    def initialize(
      access_key_id:,
      secret_access_key:,
      endpoint:,
      region: 'auto'
    )
      @s3 = Aws::S3::Client.new(
        access_key_id: access_key_id,
        secret_access_key: secret_access_key,
        endpoint: endpoint,
        region: region,
      )
    end

    # Uploads an object to the specified bucket.
    #
    # @param bucket [String] bucket name
    # @param key [String] object key in storage
    # @param body [String, IO] file content
    # @return [Hash] returns only the key of the uploaded object
    #
    # @raise [R2::Error] when an S3 service error occurs
    def upload(bucket:, key:, body:)
      handle_errors do
        @s3.put_object(
          bucket: bucket,
          key: key,
          body: body,
        )

        { key: key }
      end
    end

    private

    # Executes a block with standardized S3 error handling.
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
