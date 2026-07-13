# frozen_string_literal: true

require_relative '../test_helper'

# End-to-end test that drives the real CLI binary against a real R2 bucket.
#
# It is intentionally excluded from the default `rake`/`rake test:unit` run and
# is skipped unless valid R2 credentials are present in the environment, so it
# never performs network operations by accident.
class UploadTest < Minitest::Test
  include BinHelper
  include TempFileHelper

  REQUIRED_ENV = %w[R2_ACCESS_KEY_ID R2_SECRET_ACCESS_KEY R2_ENDPOINT].freeze

  def setup
    missing = REQUIRED_ENV.select { |name| ENV[name].to_s.strip.empty? }
    return if missing.empty?

    skip("missing R2 credentials: #{missing.join(', ')}")
  end

  def test_upload
    prefix = "r2-e2e/#{SecureRandom.hex(8)}"

    with_text do |path|
      stdout, _stderr, status = run_cmd('upload', path, '--prefix', prefix)

      assert status.success?
      assert_match(%r{\[R2\] upload -> #{Regexp.escape(prefix)}/}, stdout)
    end
  end
end
