# frozen_string_literal: true

require 'tempfile'

module TempFileHelper
  private

  # Default content used in CLI E2E tests
  TEXT = <<~TEXT
    This is a test file for R2 CLI.
    It contains some sample content.
    Line 1
    Line 2
    Line 3
  TEXT

  # Executes a block with a temporary file containing default text.
  def with_text(&)
    with_temp_file(TEXT, &)
  end

  # Creates a temporary file and yields its path to the block.
  #
  # The file is automatically removed after the block executes.
  #
  # @param content [String, nil] optional file content
  # @param ext [String] temporary file extension
  def with_temp_file(content = nil, ext = '.tmp')
    Tempfile.create(['r2', ext]) do |file|
      file.write(content) if content
      file.flush
      file.rewind

      yield file.path
    end
  end
end
