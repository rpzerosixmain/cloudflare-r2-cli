# frozen_string_literal: true

module R2
  module Commands
    class ListFiles
      def initialize(storage)
        @storage = storage
      end

      def call(options = {})
        result = @storage.list(options)

        result.to_h
      end
    end
  end
end
