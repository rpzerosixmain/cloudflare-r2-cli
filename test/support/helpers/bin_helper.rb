# frozen_string_literal: true

require 'open3'

module BinHelper
  BIN = [RbConfig.ruby, 'exe/r2'].freeze

  def run_cmd(*)
    Open3.capture3(*BIN, *)
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
end
