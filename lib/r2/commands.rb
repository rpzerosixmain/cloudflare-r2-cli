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
      def call(options = {})
        storage.list(options)
      end
    end

    class Upload < Base
      def call(key, path, options = {})
        storage.upload(key, path, options)
      end
    end

    class Download < Base
      def call(key, path, options = {})
        storage.download(key, path, options)
      end
    end

    class Delete < Base
      def call(key, options = {})
        storage.delete(key, options)
      end
    end
  end
end
