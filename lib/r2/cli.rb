# frozen_string_literal: true

require 'thor'
require 'logger'

require_relative 'cli/gateway'

module R2
  class CLI < Thor
    def self.exit_on_failure?
      true
    end

    class_option :bucket,
                 aliases: '-b',
                 default: 'main',
                 desc: 'R2 bucket name'

    class_option :verbose,
                 type: :boolean,
                 default: false,
                 desc: 'Show detailed logs'

    desc 'upload PATH [KEY]', 'Upload a file to R2'
    def upload(path, key = nil)
      gateway.upload(path, key, options)

      say('[R2] upload completed')
    end

    desc 'download KEY [PATH]', 'Download a file from R2'
    def download(key, path = nil)
      gateway.download(key, path, options)

      say('[R2] download completed')
    end

    desc 'delete KEY', 'Remove a file from R2'
    def delete(key)
      gateway.delete(key, options)

      say('[R2] delete completed')
    end

    desc 'list', 'List files in R2 bucket'
    def list
      items = gateway.list(options)

      return say('[R2] list empty') if items.empty?

      items.each do |item|
        say("#{item.key} (etag: #{item.etag})")
      end
    end

    private

    def gateway
      @gateway ||= R2::CLI::Gateway.new(client, logger: logger)
    end

    def client
      @client ||= R2::Client.new
    end

    def logger
      @logger ||= Logger.new($stderr).tap do |logger|
        logger.level = options[:verbose] ? Logger::INFO : Logger::FATAL

        logger.formatter = proc do |_severity, _datetime, _progname, msg|
          "[R2] #{msg}\n"
        end
      end
    end
  end
end
