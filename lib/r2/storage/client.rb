# frozen_string_literal: true

module R2
  module Storage
    class Client
      def initialize(config)
        s3_client = Aws::S3::Client.new(
          access_key_id: config.access_key_id,
          secret_access_key: config.secret_access_key,
          endpoint: config.endpoint,
          region: config.region,
          force_path_style: true,
          http_open_timeout: 15,
          http_read_timeout: 60,
        )

        @upload = Upload.new(s3_client)
        @download = Download.new(s3_client)
        @delete = Delete.new(s3_client)
        @list = List.new(s3_client)
      end

      def upload(key, body, options = {})
        full_key = build_key(options[:prefix], key)

        @upload.call(full_key, body, options)
      end

      def download(key, options = {})
        full_key = build_key(options[:prefix], key)

        @download.call(full_key, options)
      end

      def delete(key, options = {})
        full_key = build_key(options[:prefix], key)

        @delete.call(full_key, options)
      end

      def list(options = {})
        @list.call(options)
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
