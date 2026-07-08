# frozen_string_literal: true

require_relative '../test_helper'

class StorageTest < Minitest::Test
  def setup
    @s3 = FakeS3.new

    @storage = R2::Storage.new(
      access_key_id: 'key',
      secret_access_key: 'secret',
      endpoint: 'http://localhost',
      s3: @s3,
    )
  end

  def test_upload_delegates_to_s3_and_returns_key
    result = @storage.upload(
      bucket: 'bucket',
      key: 'file.txt',
      body: 'content',
    )

    assert_equal 'bucket', @s3.bucket
    assert_equal 'file.txt', @s3.key
    assert_equal 'content', @s3.body

    assert_equal({ key: 'file.txt' }, result)
  end

  def test_upload_forwards_content_type_when_given
    @storage.upload(
      bucket: 'bucket',
      key: 'file.txt',
      body: 'content',
      content_type: 'text/plain',
    )

    assert_equal 'text/plain', @s3.content_type
  end

  def test_upload_raises_r2_error
    @s3.error = Aws::S3::Errors::NoSuchBucket.new(nil, 'Bucket not found')

    error = assert_raises(R2::StorageError) do
      @storage.upload(
        bucket: 'bucket',
        key: 'file.txt',
        body: 'content',
      )
    end

    assert_equal 'Bucket not found', error.message
    assert_kind_of R2::Error, error
  end

  def test_upload_wraps_networking_error
    @s3.error = Seahorse::Client::NetworkingError.new(SocketError.new('boom'))

    error = assert_raises(R2::StorageError) do
      @storage.upload(
        bucket: 'bucket',
        key: 'file.txt',
        body: 'content',
      )
    end

    assert_equal 'boom', error.message
  end

  def test_upload_keeps_original_error_as_cause
    original = Aws::S3::Errors::AccessDenied.new(nil, 'Access denied')
    @s3.error = original

    error = assert_raises(R2::StorageError) do
      @storage.upload(bucket: 'bucket', key: 'file.txt', body: 'content')
    end

    assert_same original, error.cause
  end
end
