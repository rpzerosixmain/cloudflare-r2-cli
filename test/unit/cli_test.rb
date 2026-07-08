# frozen_string_literal: true

require_relative '../test_helper'

class CLITest < Minitest::Test
  def setup
    @storage = FakeStorage.new
    R2::CLI.storage = @storage
  end

  def test_upload_stores_file_and_outputs_result
    Tempfile.create(['example', '.txt']) do |file|
      file.binmode
      file.write('hello world')
      file.flush

      capture_io do
        R2::CLI.start(['upload', file.path])
      end

      assert_equal 'main', @storage.bucket
      assert_equal File.basename(file.path), @storage.key
      assert_equal 'hello world', @storage.body
    end
  end

  def test_upload_raises_file_error_when_missing
    error = assert_raises(R2::FileError) do
      capture_io do
        R2::CLI.start(['upload', '/no/such/file.txt'])
      end
    end

    assert_match(/file not found/, error.message)
  end

  def test_upload_raises_file_error_for_directory
    Dir.mktmpdir do |dir|
      error = assert_raises(R2::FileError) do
        capture_io do
          R2::CLI.start(['upload', dir])
        end
      end

      assert_match(/not a file/, error.message)
    end
  end

  def test_upload_with_custom_bucket
    Tempfile.create(['example', '.txt']) do |file|
      file.binmode
      file.write('hello world')
      file.flush

      capture_io do
        R2::CLI.start(['upload', file.path, '--bucket', 'images'])
      end

      assert_equal 'images', @storage.bucket
      assert_equal File.basename(file.path), @storage.key
      assert_equal 'hello world', @storage.body
    end
  end

  def test_verbose_lowers_log_level_and_logs
    io = StringIO.new
    @storage.logger = build_logger(io)

    with_upload(['--verbose'])

    assert_equal Logger::INFO, @storage.logger.level
    assert_match(/uploading/, io.string)
    assert_match(/uploaded/, io.string)
  end

  def test_without_verbose_keeps_error_level_and_is_quiet
    io = StringIO.new
    @storage.logger = build_logger(io)

    with_upload([])

    assert_equal Logger::ERROR, @storage.logger.level
    assert_empty io.string
  end

  private

  def build_logger(output)
    logger = Logger.new(output)
    logger.level = Logger::ERROR
    logger
  end

  def with_upload(extra_args)
    Tempfile.create(['example', '.txt']) do |file|
      file.write('hello world')
      file.flush

      capture_io do
        R2::CLI.start(['upload', file.path, *extra_args])
      end
    end
  end
end
