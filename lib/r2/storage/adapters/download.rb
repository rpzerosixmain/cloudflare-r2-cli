# frozen_string_literal: true

module R2
  module Storage
    class Download
      def initialize(client)
        @client = client
      end

      def call(key, options = {})
        resp = @client.get_object(
          bucket: options[:bucket],
          key: key,
        )

        Result.new(
          key: key,
          body: resp.body.read,
        )
      end
    end
  end
end
