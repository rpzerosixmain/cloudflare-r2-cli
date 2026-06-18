# frozen_string_literal: true

require 'aws-sdk-s3'

require_relative 'storage/config'
require_relative 'storage/result'

require_relative 'storage/adapters/upload'
require_relative 'storage/adapters/download'
require_relative 'storage/adapters/delete'
require_relative 'storage/adapters/list'

require_relative 'storage/client'

module R2
  module Storage
  end
end
