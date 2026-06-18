# frozen_string_literal: true

module R2
  module Commands
    class DeleteFile
      def initialize(storage)
        @storage = storage
      end

      def call(key, options = {})
        result = @storage.delete(key, options)

        result.to_h
      end
    end
  end
end
