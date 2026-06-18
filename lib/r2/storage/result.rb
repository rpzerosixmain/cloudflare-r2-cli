# frozen_string_literal: true

module R2
  module Storage
    class Result
      attr_reader :data

      def initialize(data = {})
        @data = data
      end

      def to_h
        data
      end
    end
  end
end
