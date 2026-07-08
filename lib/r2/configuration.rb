# frozen_string_literal: true

module R2
  # Holds and validates the settings required to talk to R2.
  #
  # Centralizes credential/endpoint configuration so the rest of the app
  # (CLI entrypoint, Storage) depends on a single validated object instead of
  # reading environment variables directly.
  class Configuration
    # Environment variables that must be present and non-blank.
    REQUIRED_ENV = %w[R2_ACCESS_KEY_ID R2_SECRET_ACCESS_KEY R2_ENDPOINT].freeze

    # Region used when R2_REGION is not provided.
    DEFAULT_REGION = 'auto'

    attr_reader :access_key_id, :secret_access_key, :endpoint, :region

    # Builds a configuration from a source of environment variables.
    #
    # @param env [#[], #fetch] source of configuration (defaults to ENV)
    # @return [R2::Configuration]
    # @raise [R2::ConfigurationError] when a required variable is missing/blank
    def self.from_env(env = ENV)
      missing = REQUIRED_ENV.select { |name| env[name].to_s.strip.empty? }

      unless missing.empty?
        raise R2::ConfigurationError,
              "missing required environment variables: #{missing.join(', ')}"
      end

      new(
        access_key_id: env['R2_ACCESS_KEY_ID'],
        secret_access_key: env['R2_SECRET_ACCESS_KEY'],
        endpoint: env['R2_ENDPOINT'],
        region: env.fetch('R2_REGION', DEFAULT_REGION),
      )
    end

    def initialize(access_key_id:, secret_access_key:, endpoint:, region: DEFAULT_REGION)
      @access_key_id = access_key_id
      @secret_access_key = secret_access_key
      @endpoint = endpoint
      @region = region
    end

    # Keyword arguments accepted by R2::Storage.new.
    #
    # @return [Hash]
    def to_h
      {
        access_key_id: access_key_id,
        secret_access_key: secret_access_key,
        endpoint: endpoint,
        region: region,
      }
    end
  end
end
