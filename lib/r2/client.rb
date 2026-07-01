# frozen_string_literal: true

require 'aws-sdk-s3'

module R2
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
