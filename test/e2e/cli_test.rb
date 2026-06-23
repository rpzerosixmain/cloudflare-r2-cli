# frozen_string_literal: true

require 'tempfile'
require 'open3'
require 'securerandom'
require 'minitest/autorun'

class CliTest < Minitest::Test
  BIN = [RbConfig.ruby, 'exe/r2'].freeze

  def setup
    @keys_to_cleanup = []
  end

  def teardown
    @keys_to_cleanup.each { |key| run_cmd_silently('delete', key) }
  end

  def test_list_returns_all_objects_from_bucket
    assert_success 'list'
  end

  def test_delete_removes_existing_object
    key = unique_key

    with_fixture_file do |file_path|
      assert_success 'upload', file_path, key
    end

    assert_success 'delete', key
  end

  def test_upload_stores_file_with_explicit_key
    key = unique_key

    with_fixture_file do |file_path|
      assert_success 'upload', file_path, key
    end

    @keys_to_cleanup << key
  end

  def test_upload_without_key_uses_explicit_key_only
    key = unique_key

    with_fixture_file do |file_path|
      assert_success 'upload', file_path, key
    end

    @keys_to_cleanup << key
  end

  def test_download_with_explicit_destination_path
    key = unique_key
    original_content = fixture_content

    with_fixture_file do |upload_path|
      assert_success 'upload', upload_path, key
    end

    with_temp_file do |download_path|
      assert_success 'download', key, download_path
      assert_equal original_content, File.read(download_path)
    end

    @keys_to_cleanup << key
  end

  def test_download_without_path_defaults_to_basename_of_key
    key = unique_key
    original_content = fixture_content

    with_fixture_file do |upload_path|
      assert_success 'upload', upload_path, key
    end

    assert_success 'download', key

    downloaded_path = File.basename(key)

    assert File.exist?(downloaded_path),
           "Expected downloaded file at #{downloaded_path}"

    assert_equal original_content, File.read(downloaded_path)

    FileUtils.rm_f(downloaded_path)

    @keys_to_cleanup << key
  end

  private

  def fixture_content
    @fixture_content ||= File.read('test/fixtures/test-file.txt')
  end

  def unique_key
    "test/#{SecureRandom.uuid}"
  end

  def assert_success(*args)
    status = run_cmd(*args)
    assert status.success?, "Command failed: #{args.join(' ')}"
  end

  def run_cmd(*)
    _stdout, _stderr, status = Open3.capture3(*BIN, *)
    status
  end

  def run_cmd_silently(*)
    Open3.capture3(*BIN, *)
  end

  def with_fixture_file(&)
    with_temp_file(fixture_content, &)
  end

  def with_temp_file(content = nil, ext: '.tmp')
    Tempfile.create(['r2-test', ext]) do |file|
      file.write(content) if content
      file.flush
      file.rewind
      yield file.path
    end
  end
end
