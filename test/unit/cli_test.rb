# frozen_string_literal: true

require_relative '../test_helper'

class CLITest < Minitest::Test
  include TempFileHelper

  def setup
    @client = FakeClient.new
    R2::CLI.client = @client
  end

  def test_upload
    with_text do |path|
      stdout = capture_io do
        R2::CLI.start(['upload', path])
      end.first

      assert_equal path, @client.key
      assert_equal 'main', @client.bucket
      assert_equal File.binread(path), @client.body

      assert_includes stdout, "[R2] upload -> #{path}"
    end
  end
end
