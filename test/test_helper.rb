# frozen_string_literal: true

require 'bundler/setup'

require 'dotenv/load'

require 'minitest/autorun'

require 'logger'
require 'open3'
require 'securerandom'
require 'stringio'
require 'tempfile'
require 'tmpdir'
require 'fileutils'

require 'r2'

Dir[File.join(__dir__, 'support', '**', '*.rb')].each do |file|
  require file
end
