# frozen_string_literal: true

require_relative '../test_helper'

class ClientTest < Minitest::Test
  def setup
    @client = R2::Client.new(
      access_key_id: ENV.fetch('R2_ACCESS_KEY_ID'),
      secret_access_key: ENV.fetch('R2_SECRET_ACCESS_KEY'),
      endpoint: ENV.fetch('R2_ENDPOINT'),
      region: ENV.fetch('R2_REGION', 'auto'),
    )
  end

  def test_upload_returns_uploaded_key
    key = "test-#{SecureRandom.uuid}.txt"

    result = @client.upload(
      bucket: 'test',
      key: key,
      body: 'Hello, R2!',
    )

    assert_equal key, result[:key]
  end

  def test_upload_with_nonexistent_bucket_raises_r2_error
    assert_raises(R2::Error) do
      @client.upload(
        bucket: 'bucket-that-does-not-exist',
        key: 'file.txt',
        body: 'data'
      )
    end
  end
end