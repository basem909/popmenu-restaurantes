# spec/support/sidekiq.rb
require "sidekiq/testing"
Sidekiq::Testing.fake!  # jobs are pushed to queues, not executed

RSpec.configure do |config|
  config.before { Sidekiq::Worker.clear_all }
end
