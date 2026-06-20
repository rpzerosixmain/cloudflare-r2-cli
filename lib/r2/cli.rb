# frozen_string_literal: true

require 'thor'

module R2
  class CLI < Thor
    def self.exit_on_failure?
      true
    end

    class_option :bucket,
                 aliases: '-b',
                 default: 'main',
                 desc: 'R2 bucket name'

    desc 'upload KEY PATH', 'Upload a file to R2'
    def upload(key, path)
      result = gateway.upload(key, path, options)

      say("[R2] upload key=#{result.key} bucket=#{result.bucket} etag=#{result.etag}")
    end

    desc 'download KEY PATH', 'Download a file from R2'
    def download(key, path)
      result = gateway.download(key, path, options)

      say("[R2] download key=#{result.key} bucket=#{result.bucket} bytes=#{result.body&.bytesize}")
    end

    desc 'delete KEY', 'Remove a file from R2'
    def delete(key)
      result = gateway.delete(key, options)

      say("[R2] delete key=#{result.key} bucket=#{result.bucket}")
    end

    desc 'list', 'List files in R2 bucket'
    def list
      items = gateway.list(options)

      if items.empty?
        say('[R2] list empty')
        return
      end

      items.each do |item|
        say("[R2] list key=#{item.key} bucket=#{item.bucket} etag=#{item.etag}")
      end
    end

    private

    def gateway
      @gateway ||= R2::Gateway.new(client)
    end

    def client
      @client ||= R2::Client.new
    end
  end
end
