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
end
