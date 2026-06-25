# frozen_string_literal: true

require 'bundler/setup'

require 'dotenv'
Dotenv.load(*Dir['.env*'])

require 'minitest/autorun'
require 'open3'
require 'securerandom'
require 'stringio'
require 'tempfile'

require 'r2'
