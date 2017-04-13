source 'https://rubygems.org'

gem 'rails', '~> 5.0.0.1'
gem 'rake'
gem 'pg'
gem 'jbuilder', '~> 2.6.0'
gem 'sidekiq'
gem 'sidekiq-unique-jobs'
gem 'typhoeus'
gem 'dotenv-rails'
gem 'puma'
gem 'sentry-raven'
gem 'addressable', '~> 2.5'
gem 'whenever', '~> 0.9', require: false

group :development, :test do
  gem 'byebug'
  %w[rails core expectations mocks support].each do |name|
    gem "rspec-#{name}", "~> 3.5.0"
  end
  gem 'factory_girl_rails'
  gem 'timecop'
  gem 'simplecov', require: false
  gem 'rails-controller-testing'
  gem 'database_cleaner'
end
