# frozen_string_literal: true

class FakeStorage
  attr_reader :bucket, :key, :body, :content_type

  def upload(bucket:, key:, body:, content_type: nil)
    @bucket = bucket
    @key = key
    @content_type = content_type
    @body = body.respond_to?(:read) ? body.read : body

    { key: key }
  end
end
