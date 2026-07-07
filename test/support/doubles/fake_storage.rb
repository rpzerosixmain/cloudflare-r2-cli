# frozen_string_literal: true

class FakeStorage
  attr_reader :bucket, :key, :body, :content_type

  def upload(bucket:, key:, body:, content_type: nil)
    @bucket = bucket
    @key = key
    @body = body.respond_to?(:read) ? body.read : body
    @content_type = content_type

    { key: key }
  end
end
