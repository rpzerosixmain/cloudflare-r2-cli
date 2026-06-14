# frozen_string_literal: true

require 'thor'

require_relative 'storage'
require_relative 'commands'

module R2
  class CLI < Thor
    def self.exit_on_failure?
      true
    end

    class_option :bucket,
                 aliases: '-b',
                 default: 'main',
                 desc: 'R2 bucket name'

    class_option :prefix,
                 aliases: '-p',
                 default: nil,
                 desc: 'Object prefix (virtual folder)'

    desc 'upload KEY PATH', 'Upload a file to R2'
    def upload(key, path)
      result = Commands::Upload.new(storage).call(key, path, options)

      say("[R2] uploaded key=#{result[:key]}")
    end

    desc 'download KEY PATH', 'Download a file from R2'
    def download(key, path)
      result = Commands::Download.new(storage).call(key, path, options)

      say("[R2] downloaded key=#{result[:key]} -> #{path}")
    end

    desc 'delete KEY', 'Remove a file from R2'
    def delete(key)
      result = Commands::Delete.new(storage).call(key, options)

      say("[R2] deleted key=#{result[:key]}")
    end

    desc 'list', 'List files in R2 bucket'
    def list
      result = Commands::List.new(storage).call(options)

      if result[:items].empty?
        say('[R2] empty bucket')
        return
      end

      result[:items].each do |item|
        say("[R2] key=#{item[:key]} size=#{item[:size]}")
      end
    end

    private

    def storage
      @storage ||= R2::Storage.build
    end
  end
end
