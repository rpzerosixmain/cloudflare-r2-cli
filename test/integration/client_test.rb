# frozen_string_literal: true

require_relative '../test_helper'

class R2ClientIntegrationTest < Minitest::Test
  BUCKET = ENV.fetch('R2_BUCKET_TEST')

  INVALID_BUCKET = 'invalid-bucket'
  MISSING_KEY = 'missing-key'

  def setup
    @client = R2::Client.new(
      access_key_id: ENV.fetch('R2_ACCESS_KEY_ID_TEST'),
      secret_access_key: ENV.fetch('R2_SECRET_ACCESS_KEY_TEST'),
      endpoint: ENV.fetch('R2_ENDPOINT_TEST'),
      region: ENV.fetch('R2_REGION_TEST', 'auto'),
    )

    @key = "integration/#{SecureRandom.hex(8)}"
  end

  def test_upload_returns_result
    result = @client.upload(
      bucket: BUCKET,
      key: @key,
      body: 'test-body',
    )

    assert_instance_of R2::Client::Result, result
  end

  def test_download_returns_result
    @client.upload(
      bucket: BUCKET,
      key: @key,
      body: 'data',
    )

    result = @client.download(
      bucket: BUCKET,
      key: @key,
    )

    assert_instance_of R2::Client::Result, result
  end

  def test_delete_returns_result
    @client.upload(
      bucket: BUCKET,
      key: @key,
      body: 'data',
    )

    result = @client.delete(
      bucket: BUCKET,
      key: @key,
    )

    assert_instance_of R2::Client::Result, result
  end

  def test_list_returns_array_of_results
    @client.upload(
      bucket: BUCKET,
      key: @key,
      body: 'data',
    )

    result = @client.list(bucket: BUCKET)

    assert_instance_of Array, result
    refute_empty result

    result.each do |item|
      assert_instance_of R2::Client::Result, item
    end
  end

  def test_upload_raises_r2_error_for_invalid_bucket
    assert_raises(R2::Error) do
      @client.upload(
        bucket: INVALID_BUCKET,
        key: @key,
        body: 'data',
      )
    end
  end

  def test_download_raises_r2_error_for_missing_key
    assert_raises(R2::Error) do
      @client.download(
        bucket: BUCKET,
        key: MISSING_KEY,
      )
    end
  end

  def test_list_raises_r2_error_for_invalid_bucket
    assert_raises(R2::Error) do
      @client.list(
        bucket: INVALID_BUCKET,
      )
    end
  end

  def test_delete_raises_r2_error_for_invalid_bucket
    assert_raises(R2::Error) do
      @client.delete(
        bucket: INVALID_BUCKET,
        key: @key,
      )
    end
  end
end
