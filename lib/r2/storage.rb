# frozen_string_literal: true

require_relative 'storage/config'
require_relative 'storage/service'

module R2
  class Storage
    def initialize(service)
      @service = service
    end

    def upload(key, path, params = {})
      body = File.binread(path)
      @service.put(key, body, params)
      { key: key }
    end

    def download(key, path, params = {})
      resp = @service.get(key, params)
      body = resp.body.read

      File.binwrite(path, body)

      { key: key, body: body }
    end

    def delete(key, params = {})
      @service.delete(key, params)

      { key: key }
    end

    def list(params = {})
      resp = @service.list(params)

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
