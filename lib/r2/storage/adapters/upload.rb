# frozen_string_literal: true

module R2
  module Storage
    class Upload
      def initialize(client)
        @client = client
      end

      def call(key, body, options = {})
        @client.put_object(
          bucket: options[:bucket],
          key: key,
          body: body,
        )

        Result.new(
          key: key,
        )
      end
    end
  end
end
