# frozen_string_literal: true

require 'aws-sdk-s3'
require 'logger'

module R2
  class Client
    class Result
      attr_reader :key, :etag, :body

      def initialize(key:, etag: nil, body: nil)
        @key = key
        @etag = etag
        @body = body
      end
    end

    attr_reader :logger

    def initialize(
      access_key_id:,
      secret_access_key:,
      endpoint:,
      region: 'auto',
      logger: Logger.new($stderr)
    )
      @s3 = Aws::S3::Client.new(
        access_key_id: access_key_id,
        secret_access_key: secret_access_key,
        endpoint: endpoint,
        region: region,
      )

      @logger = logger
    end

    def list(bucket:)
      logger.debug("list:start bucket=#{bucket}")

      result = @s3.list_objects_v2(bucket: bucket).contents.map do |object|
        Result.new(
          key: object.key,
          etag: object.etag,
        )
      end

      logger.debug("list:ok bucket=#{bucket} count=#{result.size}")

      result
    end

    def upload(bucket:, key:, body:)
      logger.debug("upload:start bucket=#{bucket} key=#{key}")

      @s3.put_object(
        bucket: bucket,
        key: key,
        body: body,
      )

      logger.debug("upload:ok bucket=#{bucket} key=#{key}")

      Result.new(key: key)
    end

    def download(bucket:, key:)
      logger.debug("download:start bucket=#{bucket} key=#{key}")

      resp = @s3.get_object(
        bucket: bucket,
        key: key,
      )

      body = resp.body.read

      logger.debug("download:ok bucket=#{bucket} key=#{key} size=#{body.bytesize}")

      Result.new(
        key: key,
        body: body,
      )
    end

    def delete(bucket:, key:)
      logger.debug("delete:start bucket=#{bucket} key=#{key}")

      @s3.delete_object(
        bucket: bucket,
        key: key,
      )

      logger.debug("delete:ok bucket=#{bucket} key=#{key}")

      Result.new(key: key)
    end
  end
end
