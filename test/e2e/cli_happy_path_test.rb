# frozen_string_literal: true

require_relative '../support/e2e_test'

class CliHappyPathTest < E2ETest
  def test_list_returns_all_objects_from_bucket
    assert_success 'list'
  end

  def test_upload_stores_file_with_explicit_key
    key = unique_key

    with_fixture_file do |file_path|
      assert_success 'upload', file_path, key
    end

    @keys_to_cleanup << key
  end

  def test_delete_removes_existing_object
    key = unique_key

    with_fixture_file do |file_path|
      assert_success 'upload', file_path, key
    end

    assert_success 'delete', key
  end

  def test_download_with_explicit_destination_path
    key = unique_key
    original_content = fixture_content

    with_fixture_file do |upload_path|
      assert_success 'upload', upload_path, key
    end

    with_temp_file do |download_path|
      assert_success 'download', key, download_path

      assert_equal original_content,
                   File.read(download_path)

      FileUtils.rm_f(download_path)
    end

    @keys_to_cleanup << key
  end

  def test_download_without_path_defaults_to_basename_of_key
    key = unique_key
    original_content = fixture_content

    with_fixture_file do |upload_path|
      assert_success 'upload', upload_path, key
    end

    assert_success 'download', key

    downloaded_path = File.basename(key)

    assert File.exist?(downloaded_path),
           "Expected downloaded file at #{downloaded_path}"

    assert_equal original_content,
                 File.read(downloaded_path)

    FileUtils.rm_f(downloaded_path)

    @keys_to_cleanup << key
  end
end
