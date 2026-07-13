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

  def test_help_runs_without_storage_or_credentials
    out, = capture_io do
      R2::CLI.start(['help'], storage_factory: -> { raise 'should not build storage' })
    end

    assert_match(/Commands:/, out)
    assert_match(/upload PATH/, out)
  end

  def test_upload_builds_storage_lazily_via_factory
    calls = 0
    factory = lambda do
      calls += 1
      @storage
    end

    with_upload(storage_factory: factory)

    assert_equal 1, calls
    assert_equal File.basename(@last_path), @storage.key
  end

  def test_upload_raises_when_no_storage_configured
    Tempfile.create(['example', '.txt']) do |file|
      file.write('data')
      file.flush

      assert_raises(R2::Error) do
        capture_io { R2::CLI.start(['upload', file.path]) }
      end
    end
  end

  def test_upload_rejects_blank_bucket
    error = assert_raises(R2::UsageError) do
      with_upload(args: ['--bucket', '  '])
    end

    assert_match(/bucket must not be blank/, error.message)
  end

  def test_upload_rejects_blank_key
    error = assert_raises(R2::UsageError) do
      with_upload(args: ['--key', '  '])
    end

    assert_match(/key must not be blank/, error.message)
  end

  private

  def build_logger(output)
    logger = Logger.new(output)
    logger.level = Logger::ERROR
    logger
  end

  def with_upload(args: [], logger: nil, storage_factory: nil)
    Tempfile.create(['example', '.txt']) do |file|
      file.write('hello world')
      file.flush
      @last_path = file.path

      config = { logger: logger }
      if storage_factory
        config[:storage_factory] = storage_factory
      else
        config[:storage] = @storage
      end

      capture_io do
        R2::CLI.start(['upload', file.path, *args], **config)
      end
    end
  end
end
