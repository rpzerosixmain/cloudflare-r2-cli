# frozen_string_literal: true

require_relative 'lib/r2/version'

Gem::Specification.new do |spec|
  spec.name = 'r2'
  spec.version = R2::VERSION
  spec.authors = ['Ruan Pablo Dos Santos Gonçalves']
  spec.email = ['rp.zerosix.main@gmail.com']

  spec.summary = 'CLI for Cloudflare R2'
  spec.description = 'Command-line interface for Cloudflare R2 over an S3-compatible API.'
  spec.homepage = 'https://github.com/rpzerosixmain/r2'
  spec.license = 'MIT'

  spec.required_ruby_version = '>= 3.2'

  spec.metadata['rubygems_mfa_required'] = 'true'
  spec.metadata['source_code_uri'] = spec.homepage

  spec.files = Dir.glob('lib/**/*.rb') + Dir.glob('exe/*') + ['README.md', 'LICENSE']
  spec.bindir = 'exe'
  spec.executables = ['r2']

  spec.add_dependency 'aws-sdk-s3', '~> 1.225.0'
  spec.add_dependency 'dotenv', '~> 3.2.0'
  spec.add_dependency 'marcel', '~> 1.0.4'
  spec.add_dependency 'rexml', '~> 3.4.4'
  spec.add_dependency 'thor', '~> 1.5.0'
end
