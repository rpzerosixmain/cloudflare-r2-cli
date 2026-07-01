# frozen_string_literal: true

require 'tempfile'

module TempFileHelper
  private

  TEXT = <<~TEXT
    This is a test file for R2 CLI.
    It contains some sample content.
    Line 1
    Line 2
    Line 3
  TEXT

  def with_text(&)
    with_temp_file(TEXT, &)
  end

  def with_temp_file(content = nil, ext: '.tmp')
    Tempfile.create(['r2', ext]) do |file|
      file.write(content) if content
      file.flush
      file.rewind

      yield file.path
    end
  end
end
