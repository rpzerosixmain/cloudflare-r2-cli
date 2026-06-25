# frozen_string_literal: true

require 'aws-sdk-s3'

module R2
  class Client
    class Result
      attr_reader :key, :body

      def initialize(key: nil, body: nil)
        @key = key
        @body = body
      end
    end

    def initialize(
      access_key_id:,
      secret_access_key:,
      endpoint:,
      region: 'auto',
      logger: nil
    )
      @logger = logger

      @s3 = Aws::S3::Client.new(
        access_key_id: access_key_id,
        secret_access_key: secret_access_key,
        endpoint: endpoint,
        region: region,
      )
    end

    def list(bucket:)
      handle_errors do
        @s3.list_objects_v2(bucket: bucket).contents.map do |object|
          Result.new(key: object.key)
        end
      end
    end

    def upload(bucket:, key:, body:)
      handle_errors do
        @s3.put_object(
          bucket: bucket,
          key: key,
          body: body,
        )

        Result.new(key: key)
      end
    end

    def download(bucket:, key:)
      handle_errors do
        resp = @s3.get_object(
          bucket: bucket,
          key: key,
        )

        Result.new(
          key: key,
          body: resp.body.read,
        )
      end
    end

    def delete(bucket:, key:)
      handle_errors do
        @s3.delete_object(
          bucket: bucket,
          key: key,
        )

        Result.new(key: key)
      end
    end

    private

    def handle_errors
      yield
    rescue Aws::S3::Errors::NoSuchBucket,
           Aws::S3::Errors::NoSuchKey,
           Aws::S3::Errors::AccessDenied,
           Aws::Errors::ServiceError => e
      @logger&.error(e.message)

      raise R2::Error, e.message
    end
  end
end
