require 'rails_helper'

RSpec.configure do |config|
  config.swagger_root = Rails.root.join('swagger').to_s
  config.swagger_format = :yaml
end
