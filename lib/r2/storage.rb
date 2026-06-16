# frozen_string_literal: true

require_relative 'storage/config'
require_relative 'storage/service'

module R2
  class Storage
    def initialize(service)
      @service = service
    end

    def upload(key, path, options = {})
      body = File.binread(path)

      @service.put(key, body, options)

      { key: key }
    end

    def download(key, path, options = {})
      resp = @service.get(key, options)
      body = resp.body.read

      File.binwrite(path, body)

      { key: key, body: body }
    end

    def delete(key, options = {})
      @service.delete(key, options)

      { key: key }
    end

    def list(options = {})
      resp = @service.list(options)

      {
        items: resp.contents.map { |item| { key: item.key, size: item.size } },
      }
    end

    def self.build
      config = Config.from_env
      new(Service.new(config))
    end
  end
end
