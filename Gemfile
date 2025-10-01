source "https://rubygems.org"

ruby "3.2.4"

gem "rails", "~> 7.2.2", ">= 7.2.2.2"
gem "pg", "~> 1.5"
gem "puma", "~> 7.0"
gem "bootsnap", require: false
gem "tzinfo-data", platforms: %i[windows jruby]
gem "devise"
gem "devise-jwt", "~> 0.12.1"
gem "dotenv-rails"
gem "sidekiq"

group :development do
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false
  gem "yard", require: false
end

group :development, :test do
  gem "debug", platforms: %i[mri windows], require: "debug/prelude"
  gem "rspec-rails"
  gem "factory_bot_rails"
  gem "faker"
  gem "simplecov", require: false
  gem "shoulda-matchers"
  gem "rswag-api",   "~> 2.13"
  gem "rswag-ui",    "~> 2.13"
  gem "rswag-specs", "~> 2.13"
end
