# frozen_string_literal: true

require_relative '../test_helper'

class ConfigurationTest < Minitest::Test
  def test_from_env_builds_configuration
    config = R2::Configuration.from_env(
      'R2_ACCESS_KEY_ID' => 'key',
      'R2_SECRET_ACCESS_KEY' => 'secret',
      'R2_ENDPOINT' => 'http://localhost',
      'R2_REGION' => 'us-east-1',
    )

    assert_equal 'key', config.access_key_id
    assert_equal 'secret', config.secret_access_key
    assert_equal 'http://localhost', config.endpoint
    assert_equal 'us-east-1', config.region
  end

  def test_from_env_defaults_region
    config = R2::Configuration.from_env(
      'R2_ACCESS_KEY_ID' => 'key',
      'R2_SECRET_ACCESS_KEY' => 'secret',
      'R2_ENDPOINT' => 'http://localhost',
    )

    assert_equal R2::Configuration::DEFAULT_REGION, config.region
  end

  def test_from_env_raises_when_required_missing
    error = assert_raises(R2::ConfigurationError) do
      R2::Configuration.from_env('R2_ACCESS_KEY_ID' => 'key')
    end

    assert_match(/R2_SECRET_ACCESS_KEY/, error.message)
    assert_match(/R2_ENDPOINT/, error.message)
  end

  def test_from_env_treats_blank_as_missing
    error = assert_raises(R2::ConfigurationError) do
      R2::Configuration.from_env(
        'R2_ACCESS_KEY_ID' => '  ',
        'R2_SECRET_ACCESS_KEY' => 'secret',
        'R2_ENDPOINT' => 'http://localhost',
      )
    end

    assert_match(/R2_ACCESS_KEY_ID/, error.message)
  end

  def test_to_h_matches_storage_keyword_arguments
    config = R2::Configuration.new(
      access_key_id: 'key',
      secret_access_key: 'secret',
      endpoint: 'http://localhost',
    )

    assert_equal(
      {
        access_key_id: 'key',
        secret_access_key: 'secret',
        endpoint: 'http://localhost',
        region: 'auto',
      },
      config.to_h,
    )
  end
end
