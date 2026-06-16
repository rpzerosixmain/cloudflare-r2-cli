# frozen_string_literal: true

require 'minitest/autorun'
require 'open3'

class E2ETest < Minitest::Test
  BIN = [RbConfig.ruby, 'exe/r2'].freeze
  FILE = 'example.txt'
  FIXTURE = 'test/fixtures/example.txt'

  def run_command(*)
    Open3.capture3(*BIN, *)
  end

  def assert_command_success(*args)
    stdout, stderr, status = run_command(*args)

    assert status.success?,
           "Command failed: #{args.join(' ')}\nSTDOUT: #{stdout}\nSTDERR: #{stderr}"
  end

  def test_list
    assert_command_success('list')
  end

  def test_upload_download_delete_flow
    Dir.mktmpdir do |tmpdir|
      downloaded_file = File.join(tmpdir, FILE)

      assert_command_success('upload', FILE, FIXTURE)

      assert_command_success('download', FILE, downloaded_file)
      assert File.exist?(downloaded_file),
             "Downloaded file should exist: #{downloaded_file}"

      assert_command_success('delete', FILE)
    end
  end
end
