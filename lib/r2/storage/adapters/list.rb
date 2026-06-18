# frozen_string_literal: true

module R2
  module Storage
    class List
      def initialize(client)
        @client = client
      end

      def call(options = {})
        resp = @client.list_objects_v2(
          bucket: options[:bucket],
          prefix: options[:prefix],
        )

        Result.new(
          items: resp.contents.map do |item|
            {
              key: item.key,
              size: item.size,
            }
          end,
        )
      end
    end
  end
end
