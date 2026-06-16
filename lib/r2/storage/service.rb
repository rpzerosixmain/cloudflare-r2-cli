# frozen_string_literal: true

require 'aws-sdk-s3'

module R2
  class Storage
    class Service
      def initialize(config)
        @config = config

        @s3 = Aws::S3::Client.new(
          access_key_id: config.access_key_id,
          secret_access_key: config.secret_access_key,
          endpoint: config.endpoint,
          region: config.region,
          force_path_style: true,
          http_open_timeout: 15,
          http_read_timeout: 60,
        )
      end

      def put(key, body, options = {})
        @s3.put_object(
          bucket: options[:bucket],
          key: build_key(options[:prefix], key),
          body: body,
        )
      end

      def get(key, options = {})
        @s3.get_object(
          bucket: options[:bucket],
          key: build_key(options[:prefix], key),
        )
      end

      def delete(key, options = {})
        @s3.delete_object(
          bucket: options[:bucket],
          key: build_key(options[:prefix], key),
        )
      end

      def list(options = {})
        @s3.list_objects_v2(
          bucket: options[:bucket],
          prefix: options[:prefix],
        )
      end

      private

      def build_key(prefix, key)
        [prefix, key.to_s.strip]
          .compact
          .reject(&:empty?)
          .join('/')
      end
    end
  end
end
