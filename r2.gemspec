# frozen_string_literal: true

require_relative 'lib/r2/version'

Gem::Specification.new do |spec|
  spec.name = 'cloudflare-r2-cli'
  spec.version = R2::VERSION
  spec.authors = ['Ruan Pablo Dos Santos Gonçalves']
  spec.email = ['rp.zerosix.main@gmail.com']

  spec.summary = 'CLI for Cloudflare R2'
  spec.description = 'A simple CLI to interact with Cloudflare R2 via an S3-compatible API.'
  spec.homepage = 'https://github.com/rpzerosixmain/cloudflare-r2-cli'
  spec.license = 'MIT'

  spec.required_ruby_version = '>= 3.3'

  spec.metadata['rubygems_mfa_required'] = 'true'
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  spec.files = Dir.glob('lib/**/*.rb') +
               Dir.glob('exe/*') +
               ['README.md', 'CHANGELOG.md', 'LICENSE']
  spec.bindir = 'exe'
  spec.executables = ['r2']

  spec.add_dependency 'aws-sdk-s3', '>= 1.225', '< 1.229'
  spec.add_dependency 'dotenv', '~> 3.2.0'
  spec.add_dependency 'marcel', '~> 1.0'
  spec.add_dependency 'rexml', '~> 3.4.4'
  spec.add_dependency 'thor', '~> 1.5.0'

  spec.add_development_dependency 'bundler-audit', '~> 0.9.3'
  spec.add_development_dependency 'minitest', '~> 6.0'
  spec.add_development_dependency 'rake', '~> 13.2'
  spec.add_development_dependency 'rubocop', '~> 1.75'
end
