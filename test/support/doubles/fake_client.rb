# frozen_string_literal: true

class FakeClient
  attr_reader :bucket, :key, :body

  def upload(bucket:, key:, body:)
    @bucket = bucket
    @key = key
    @body = body

    { key: key }
  end
end
