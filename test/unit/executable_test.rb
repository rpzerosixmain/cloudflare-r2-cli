# frozen_string_literal: true

require_relative '../test_helper'

class ExecutableTest < Minitest::Test
  include BinHelper

  def test_help_does_not_require_credentials
    stdout, stderr, status = run_cmd_without_credentials('help')

    assert status.success?, stderr
    assert_match(/Commands:/, stdout)
    assert_empty stderr
  end

  def test_storage_command_reports_missing_credentials_once_on_stderr
    Tempfile.create(['example', '.txt']) do |file|
      file.write('data')
      file.flush

      stdout, stderr, status = run_cmd_without_credentials('upload', file.path)

      refute status.success?
      assert_empty stdout
      assert_equal 1, stderr.lines.grep(/missing required environment variables/).length
      refute_match(%r{lib/r2}, stderr)
    end
  end

  private

  def run_cmd_without_credentials(*)
    env = R2::Configuration::REQUIRED_ENV.to_h { |name| [name, nil] }
    Open3.capture3(env, *BinHelper::BIN, *)
  end
end
