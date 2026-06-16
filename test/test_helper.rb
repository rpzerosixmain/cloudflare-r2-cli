# frozen_string_literal: true

require 'minitest/autorun'
require 'dotenv/load'

test_root = File.expand_path(__dir__)

Dir[File.join(test_root, '**', '*_test.rb')].each do |file|
  require file
end
