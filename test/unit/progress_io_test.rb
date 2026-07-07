# frozen_string_literal: true

require_relative '../test_helper'

class ProgressIOTest < Minitest::Test
  def setup
    @source = StringIO.new('hello world')
    @output = StringIO.new
    @io = R2::ProgressIO.new(@source, total: @source.size, output: @output)
  end

  def test_read_returns_underlying_content
    assert_equal 'hello', @io.read(5)
    assert_equal ' world', @io.read(6)
    assert_nil @io.read(5)
  end

  def test_read_renders_progress
    @io.read

    assert_includes @output.string, '[R2] uploading 100%'
  end

  def test_size_reports_total
    assert_equal @source.size, @io.size
  end

  def test_rewind_resets_source
    @io.read
    @io.rewind

    assert_equal 'hello world', @io.read
  end
end
