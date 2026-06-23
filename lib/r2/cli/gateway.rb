# frozen_string_literal: true

require 'thor'
require 'logger'

module R2
  class CLI < Thor
    class Gateway
      def initialize(client, logger: Logger.new($stderr))
        @client = client
        @logger = logger
      end

      def upload(path, key = nil, options = {})
        bucket = options.fetch(:bucket)

        key ||= File.basename(path)

        body = File.binread(path)

        result = @client.upload(
          key: key,
          bucket: bucket,
          body: body,
        )

        @logger.info(
          "upload key=#{result.key} bucket=#{result.bucket} etag=#{result.etag}",
        )

        result
      end

      def download(key, path = nil, options = {})
        bucket = options.fetch(:bucket)

        result = @client.download(
          key: key,
          bucket: bucket,
        )

        path ||= File.basename(key)

        File.binwrite(path, result.body)

        @logger.info(
          "download key=#{result.key} bucket=#{result.bucket} bytes=#{result.body&.bytesize}",
        )

        result
      end

      def delete(key, options = {})
        bucket = options.fetch(:bucket)

        result = @client.delete(
          key: key,
          bucket: bucket,
        )

        @logger.info(
          "delete key=#{result.key} bucket=#{result.bucket}",
        )

        result
      end

      def list(options = {})
        bucket = options.fetch(:bucket)

        @client.list(bucket: bucket)
      end
    end
  end
end
