# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'

ENV['RAILS_ENV'] ||= 'test'

# Ensure JWT secret exists **before** Rails initializers load
ENV['DEVISE_JWT_SECRET_KEY'] ||= 'test_secret_change_me'

require_relative '../config/environment'

# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?

require 'rspec/rails'
require 'sidekiq/testing'
require 'rswag/specs'

# Ensures that the test database schema matches the current schema file.
# If there are pending migrations it will invoke `db:test:prepare`.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

RSpec.configure do |config|
  # Fixture path (if you use fixtures)
  config.fixture_paths = [ Rails.root.join('spec/fixtures') ]

  # Use transactions for speed & isolation
  config.use_transactional_fixtures = true

  # FactoryBot shorthand: create(:menu) instead of FactoryBot.create(:menu)
  config.include FactoryBot::Syntax::Methods

  # Load support files (json helpers, auth helpers, etc.)
  Dir[Rails.root.join("spec/support/**/*.rb")].sort.each { |f| require f }

  # Make helpers available to request specs
  config.include JsonHelpers, type: :request
  config.include AuthHelpers, type: :request

  # Sidekiq in test mode
  Sidekiq::Testing.fake!
  config.before { Sidekiq::Worker.clear_all }

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!

  # Rswag configuration
  config.swagger_docs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.3',
      info: {
        title: 'Popmenu Restaurantes API',
        version: 'v1',
        description: 'API for managing restaurants, menus, and menu items'
      },
      servers: [
        {
          url: 'http://127.0.0.1:3000',
          description: 'Local development server'
        }
      ],
      components: {
        securitySchemes: {
          bearerAuth: {
            type: :http,
            scheme: :bearer,
            bearerFormat: 'JWT'
          }
        }
      }
    }
  }
end

# Shoulda Matchers config (single place)
Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
