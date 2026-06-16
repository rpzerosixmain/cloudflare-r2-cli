# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = 'r2'
  spec.authors = ['Ruan Pablo Dos Santos Gonçalves']
  spec.version = '0.0.0'
  spec.summary = 'CLI for Cloudflare R2'

  spec.required_ruby_version = '>= 3.1'

  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.add_dependency 'aws-sdk-s3'
  spec.add_dependency 'dotenv'
  spec.add_dependency 'rexml'
  spec.add_dependency 'thor'

  spec.add_development_dependency 'minitest'
end
