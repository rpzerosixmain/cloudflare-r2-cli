# frozen_string_literal: true

require 'thor'

module R2
  class CLI < Thor
    class << self
      attr_accessor :gateway
    end

    def self.exit_on_failure?
      true
    end

    class_option :bucket,
                 aliases: '-b',
                 default: 'main',
                 desc: 'R2 bucket name'

    desc 'upload PATH [KEY]', 'Upload a file to R2'
    def upload(path, key = nil)
      result = gateway.upload(
        path: path,
        key: key,
        options: options,
      )

      say("[R2] uploaded: #{result.key}")
    end

    desc 'download KEY [PATH]', 'Download a file from R2'
    def download(key, path = nil)
      result = gateway.download(
        key: key,
        path: path,
        options: options,
      )

      say("[R2] downloaded: #{result.key}")
    end

    desc 'delete KEY', 'Remove a file from R2'
    def delete(key)
      result = gateway.delete(
        key: key,
        options: options,
      )

      say("[R2] deleted: #{result.key}")
    end

    desc 'list', 'List files in R2 bucket'
    def list
      items = gateway.list(options: options)

      if items.empty?
        say('[R2] bucket is empty')
        return
      end

      items.each do |item|
        say("[R2] #{item.key} (etag: #{item.etag})")
      end
    end

    private

    def gateway
      self.class.gateway
    end
  end
end