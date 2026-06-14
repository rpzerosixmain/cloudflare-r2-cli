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

      def put(key, body, params = {})
        @s3.put_object(
          bucket: params[:bucket],
          key: build_key(params[:prefix], key),
          body: body,
        )
      end

      def get(key, params = {})
        @s3.get_object(
          bucket: params[:bucket],
          key: build_key(params[:prefix], key),
        )
      end

      def delete(key, params = {})
        @s3.delete_object(
          bucket: params[:bucket],
          key: build_key(params[:prefix], key),
        )
      end

      def list(params = {})
        @s3.list_objects_v2(
          bucket: params[:bucket],
          prefix: params[:prefix],
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
