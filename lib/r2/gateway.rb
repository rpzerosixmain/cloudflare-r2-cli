# frozen_string_literal: true

module R2
  class Gateway
    def initialize(client:)
      @client = client
    end

    def upload(path:, key: nil, options: {})
      bucket = fetch_bucket(options)

      key ||= File.basename(path)
      body = File.binread(path)

      @client.upload(
        key: key,
        bucket: bucket,
        body: body,
      )
    end

    def download(key:, path: nil, options: {})
      bucket = fetch_bucket(options)

      result = @client.download(
        key: key,
        bucket: bucket,
      )

      path ||= File.basename(key)
      File.binwrite(path, result.body)

      result
    end

    def delete(key:, options: {})
      bucket = fetch_bucket(options)

      @client.delete(
        key: key,
        bucket: bucket,
      )
    end

    def list(options: {})
      bucket = fetch_bucket(options)

      @client.list(bucket: bucket)
    end

    private

    def fetch_bucket(options)
      options.fetch(:bucket)
    end
  end
end
