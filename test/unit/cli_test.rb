# frozen_string_literal: true

require_relative '../test_helper'

class CLITest < Minitest::Test
  def setup
    @storage = FakeStorage.new
  end

  def test_upload_stores_file_and_outputs_result
    with_upload

    assert_equal 'main', @storage.bucket
    assert_equal File.basename(@last_path), @storage.key
    assert_equal 'hello world', @storage.body
  end

  def test_upload_sets_content_type_from_extension
    with_upload

    assert_equal 'text/plain', @storage.content_type
  end

  def test_upload_raises_file_error_when_missing
    error = assert_raises(R2::FileError) do
      capture_io do
        R2::CLI.start(['upload', '/no/such/file.txt'], storage: @storage)
      end
    end

    assert_match(/file not found/, error.message)
  end

  def test_upload_raises_file_error_for_directory
    Dir.mktmpdir do |dir|
      error = assert_raises(R2::FileError) do
        capture_io do
          R2::CLI.start(['upload', dir], storage: @storage)
        end
      end

      assert_match(/not a file/, error.message)
    end
  end

  def test_upload_with_custom_bucket
    with_upload(args: ['--bucket', 'images'])

    assert_equal 'images', @storage.bucket
    assert_equal File.basename(@last_path), @storage.key
  end

  def test_upload_with_prefix_builds_folder_key
    with_upload(args: ['--prefix', 'photos/'])

    assert_equal "photos/#{File.basename(@last_path)}", @storage.key
  end

  def test_upload_with_explicit_key_overrides_prefix
    with_upload(args: ['--prefix', 'photos', '--key', 'custom/name.txt'])

    assert_equal 'custom/name.txt', @storage.key
  end

  def test_upload_without_injected_logger_uses_null_logger
    with_upload(logger: nil)

    assert_equal File.basename(@last_path), @storage.key
  end

  def test_verbose_lowers_log_level_and_logs
    output = StringIO.new
    logger = build_logger(output)

    with_upload(args: ['--verbose'], logger: logger)

    assert_equal Logger::INFO, logger.level
    assert_match(/uploading/, output.string)
    assert_match(/uploaded/, output.string)
  end

  def test_without_verbose_keeps_error_level_and_is_quiet
    output = StringIO.new
    logger = build_logger(output)

    with_upload(logger: logger)

    assert_equal Logger::ERROR, logger.level
    assert_empty output.string
  end

  private

  def build_logger(output)
    logger = Logger.new(output)
    logger.level = Logger::ERROR
    logger
  end

  def with_upload(args: [], logger: nil)
    Tempfile.create(['example', '.txt']) do |file|
      file.write('hello world')
      file.flush
      @last_path = file.path

      capture_io do
        R2::CLI.start(['upload', file.path, *args], storage: @storage, logger: logger)
      end
    end
  end
end
