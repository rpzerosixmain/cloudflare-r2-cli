# frozen_string_literal: true

require 'thor'

module R2
  class CLI < Thor
    class << self
      attr_accessor :client
    end

    def self.exit_on_failure?
      true
    end

    class_option :bucket,
                 aliases: '-b',
                 default: 'main',
                 desc: 'R2 bucket name'

    desc 'upload PATH', 'Upload a file to R2'
    def upload(path)
      result = client.upload(
        key: path,
        bucket: options.fetch(:bucket),
        body: File.binread(path),
      )

      say("[R2] upload -> #{result[:key]}")
    end

    private

    def client
      self.class.client
    end
  end
end
