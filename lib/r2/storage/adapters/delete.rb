# frozen_string_literal: true

module R2
  module Storage
    class Delete
      def initialize(client)
        @client = client
      end

      def call(key, options = {})
        @client.delete_object(
          bucket: options[:bucket],
          key: key,
        )

        Result.new(
          key: key,
        )
      end
    end
  end
end
