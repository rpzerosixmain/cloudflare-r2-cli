# frozen_string_literal: true

require 'uri'

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
    # @raise [R2::ConfigurationError] when required values are invalid
    def self.from_env(env = ENV)
      values = required_values(env)
      endpoint = values.fetch('R2_ENDPOINT')
      validate_endpoint!(endpoint)

      new(
        access_key_id: values.fetch('R2_ACCESS_KEY_ID'),
        secret_access_key: values.fetch('R2_SECRET_ACCESS_KEY'),
        endpoint: endpoint,
        region: region_from(env),
      )
    end

    def self.required_values(env)
      values = REQUIRED_ENV.to_h { |name| [name, env[name].to_s.strip] }
      missing = values.select { |_name, value| value.empty? }.keys
      return values if missing.empty?

      raise R2::ConfigurationError,
            "missing required environment variables: #{missing.join(', ')}"
    end
    private_class_method :required_values

    def self.region_from(env)
      region = env.fetch('R2_REGION', DEFAULT_REGION).to_s.strip
      region.empty? ? DEFAULT_REGION : region
    end
    private_class_method :region_from

    def self.validate_endpoint!(endpoint)
      uri = URI.parse(endpoint)
      return if uri.is_a?(URI::HTTPS) && uri.host

      raise R2::ConfigurationError, 'R2_ENDPOINT must be a valid HTTPS URL'
    rescue URI::InvalidURIError
      raise R2::ConfigurationError, 'R2_ENDPOINT must be a valid HTTPS URL'
    end
    private_class_method :validate_endpoint!

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
