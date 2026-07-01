# frozen_string_literal: true

require 'open3'

module BinHelper
  # Path to the CLI binary being tested.
  BIN = [RbConfig.ruby, 'exe/r2'].freeze

  # Executes a command in the CLI and returns stdout, stderr, and status.
  def run_cmd(*)
    Open3.capture3(*BIN, *)
  end

  # Asserts that the command executed successfully (exit code 0).
  def assert_success(*args)
    _stdout, _stderr, status = run_cmd(*args)

    assert status.success?,
           "Command failed: #{args.join(' ')}"
  end

  # Asserts that the command failed (non-zero exit code).
  def assert_failure(*args)
    _stdout, _stderr, status = run_cmd(*args)

    refute status.success?,
           "Expected command to fail: #{args.join(' ')}"
  end
end
