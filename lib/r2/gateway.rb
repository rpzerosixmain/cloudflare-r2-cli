# frozen_string_literal: true

module R2
  class Gateway
    def initialize(client)
      @client = client
    end

    def upload(key, path, options = {})
      bucket = options.fetch(:bucket)

      body = File.binread(path)

      @client.upload(
        bucket: bucket,
        key: key,
        body: body,
      )
    end

    def download(key, path, options = {})
      bucket = options.fetch(:bucket)

      result = @client.download(
        bucket: bucket,
        key: key,
      )

      File.binwrite(path, result.body)

      result
    end

    def delete(key, options = {})
      bucket = options.fetch(:bucket)

      @client.delete(
        bucket: bucket,
        key: key,
      )
    end

    def list(options = {})
      bucket = options.fetch(:bucket)

      @client.list(bucket: bucket)
    end
  end
end
