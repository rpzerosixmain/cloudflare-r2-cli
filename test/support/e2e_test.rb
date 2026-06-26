# frozen_string_literal: true

require_relative '../test_helper'

class E2ETest < Minitest::Test
  BIN = [RbConfig.ruby, 'exe/r2'].freeze

  def setup
    @keys_to_cleanup = []
  end

  def teardown
    @keys_to_cleanup.each { |key| run_cmd('delete', key) }
  end

  private

  def fixture_content
    @fixture_content ||= File.read('test/fixtures/files/data.txt')
  end

  def unique_key
    "test/#{SecureRandom.uuid}"
  end

  def assert_success(*args)
    _stdout, _stderr, status = run_cmd(*args)

    assert status.success?,
           "Command failed: #{args.join(' ')}"
  end

  def assert_failure(*args)
    _stdout, _stderr, status = run_cmd(*args)

    refute status.success?,
           "Expected command to fail: #{args.join(' ')}"
  end

  def run_cmd(*)
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
