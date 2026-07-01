# frozen_string_literal: true

require_relative '../test_helper'

class UploadTest < Minitest::Test
  include BinHelper
  include TempFileHelper

  def test_upload_succeeds_with_valid_file
    with_text do |path|
      _, _stderr, status = run_cmd('upload', path)

      assert status.success?
    end
  end
end
