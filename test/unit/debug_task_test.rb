# frozen_string_literal: true

require_relative '../test_helper'

class DebugTaskTest < Minitest::Test
  RAKE = [RbConfig.ruby, '-S', 'bundle', 'exec', 'rake'].freeze

  def test_clean_rejects_project_root
    _stdout, stderr, status = Open3.capture3(
      { 'R2_DEBUG_DIR' => '.' },
      *RAKE,
      'debug:clean',
    )

    refute status.success?
    assert_match(/refusing to use debug dir outside the project/, stderr)
  end

  def test_clean_rejects_symlink_outside_project
    Dir.mktmpdir('r2-debug-outside-') do |outside|
      link = File.join(Dir.pwd, "r2-debug-link-#{SecureRandom.hex(6)}")
      File.symlink(outside, link)

      _stdout, stderr, status = Open3.capture3(
        { 'R2_DEBUG_DIR' => File.basename(link) },
        *RAKE,
        'debug:clean',
      )

      refute status.success?
      assert_match(/refusing to use debug dir outside the project/, stderr)
    ensure
      FileUtils.rm_f(link) if link
    end
  end

  def test_clean_removes_only_generated_debug_files
    Dir.mktmpdir('r2-debug-', Dir.pwd) do |dir|
      generated = File.join(dir, '20260713_190000_10mb.bin')
      unrelated = File.join(dir, 'keep.txt')
      File.write(generated, 'debug')
      File.write(unrelated, 'keep')

      stdout, stderr, status = Open3.capture3(
        { 'R2_DEBUG_DIR' => File.basename(dir) },
        *RAKE,
        'debug:clean',
      )

      assert status.success?, stderr
      assert_match(/removed 1 file/, stdout)
      refute_path_exists generated
      assert_path_exists unrelated
    end
  end
end
