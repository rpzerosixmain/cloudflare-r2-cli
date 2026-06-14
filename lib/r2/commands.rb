# frozen_string_literal: true

module R2
  module Commands
    class Base
      attr_reader :storage

      def initialize(storage)
        @storage = storage
      end
    end

    class List < Base
      def call(params = {})
        storage.list(params)
      end
    end

    class Upload < Base
      def call(key, path, params = {})
        storage.upload(key, path, params)
      end
    end

    class Download < Base
      def call(key, path, params = {})
        storage.download(key, path, params)
      end
    end

    class Delete < Base
      def call(key, params = {})
        storage.delete(key, params)
      end
    end
  end
end
