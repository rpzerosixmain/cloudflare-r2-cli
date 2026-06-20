# frozen_string_literal: true

require 'aws-sdk-s3'

module R2
  class Result
    attr_reader :key,
                :bucket,
                :etag,
                :body

    def initialize(key:, bucket:, etag: nil, body: nil)
      @key = key
      @bucket = bucket
      @etag = etag
      @body = body
    end

    def to_h
      {
        key: key,
        bucket: bucket,
        etag: etag,
        body: body,
      }
    end
  end

  class Client
    ACCESS_KEY_ID     = ENV.fetch('R2_ACCESS_KEY_ID')
    SECRET_ACCESS_KEY = ENV.fetch('R2_SECRET_ACCESS_KEY')
    ENDPOINT          = ENV.fetch('R2_ENDPOINT')
    REGION            = ENV.fetch('R2_REGION', 'auto')

    def initialize(
      access_key_id: ACCESS_KEY_ID,
      secret_access_key: SECRET_ACCESS_KEY,
      endpoint: ENDPOINT,
      region: REGION
    )
      @s3 = Aws::S3::Client.new(
        access_key_id: access_key_id,
        secret_access_key: secret_access_key,
        endpoint: endpoint,
        region: region,
      )
    end

    def list(bucket:)
      @s3.list_objects_v2(bucket: bucket).contents.map do |object|
        Result.new(
          key: object.key,
          bucket: bucket,
          etag: object.etag,
        )
      end
    end

    def upload(bucket:, key:, body:)
      resp = @s3.put_object(
        bucket: bucket,
        key: key,
        body: body,
      )

      Result.new(
        key: key,
        bucket: bucket,
        etag: resp.etag,
      )
    end

    def download(bucket:, key:)
      resp = @s3.get_object(
        bucket: bucket,
        key: key,
      )

      Result.new(
        key: key,
        bucket: bucket,
        etag: resp.etag,
        body: resp.body.read,
      )
    end

    def delete(bucket:, key:)
      @s3.delete_object(
        bucket: bucket,
        key: key,
      )

      Result.new(
        key: key,
        bucket: bucket,
      )
    end
  end
end
