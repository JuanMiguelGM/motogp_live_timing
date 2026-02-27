# frozen_string_literal: true

source 'https://rubygems.org'

gem 'rails', '~> 8.1.2'
gem 'propshaft'
gem 'sqlite3', '>= 2.1'
gem 'puma', '>= 5.0'
gem 'importmap-rails'
gem 'turbo-rails'
gem 'stimulus-rails'
gem 'tailwindcss-rails'
gem 'tzinfo-data', platforms: %i[windows jruby]
gem 'solid_cable'
gem 'solid_cache'
gem 'solid_queue'
gem 'bootsnap', require: false
gem 'kamal', require: false
gem 'thruster', require: false
gem 'concurrent-ruby'

group :development, :test do
  gem 'debug', platforms: %i[mri windows], require: 'debug/prelude'
  gem 'bundler-audit', require: false
  gem 'brakeman', require: false
  gem 'rubocop', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'factory_bot_rails'
  gem 'rspec-rails'
end

group :development do
  gem 'web-console'
end

group :test do
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'webmock'
end
