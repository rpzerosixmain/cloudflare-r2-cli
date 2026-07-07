# frozen_string_literal: true

class FakeS3
  attr_reader :bucket, :key, :body, :content_type

  attr_accessor :error

  def put_object(bucket:, key:, body:, content_type: nil)
    raise error if error

    @bucket = bucket
    @key = key
    @body = body
    @content_type = content_type
  end
end
