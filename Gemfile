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

group :development, :test do
  gem 'byebug'
  %w[rails core expectations mocks support].each do |name|
    gem "rspec-#{name}"
  end
  gem 'factory_girl_rails'
  gem 'timecop'
  gem 'simplecov', require: false
  gem 'rails-controller-testing'
  gem 'database_cleaner'
end
