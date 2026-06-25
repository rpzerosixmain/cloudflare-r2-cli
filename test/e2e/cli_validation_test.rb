# frozen_string_literal: true

require_relative '../support/e2e_test'

class CliValidationTest < E2ETest
  def test_upload_requires_path
    assert_failure 'upload'
  end

  def test_download_requires_key
    assert_failure 'download'
  end

  def test_delete_requires_key
    assert_failure 'delete'
  end

  def test_unknown_command_fails
    assert_failure 'unknown-command'
  end
end
