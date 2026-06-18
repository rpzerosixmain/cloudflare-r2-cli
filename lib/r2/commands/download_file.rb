# frozen_string_literal: true

module R2
  module Commands
    class DownloadFile
      def initialize(storage)
        @storage = storage
      end

      def call(key, path, options = {})
        result = @storage.download(key, options)

        File.binwrite(path, result.data[:body])

        result.to_h
      end
    end
  end
end
