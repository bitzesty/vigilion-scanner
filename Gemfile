source 'https://rubygems.org'

gem 'rails', '~> 5.0.6'
gem 'rake', '~> 11.2'
gem 'pg', '~> 0.18'
gem 'jbuilder', '~> 2.6.0'
gem 'typhoeus', '~> 1.1'
gem 'dotenv-rails', '~> 2.1'
gem 'puma', '~> 3.12'
gem 'sentry-raven', '~> 1.2'
gem 'addressable', '~> 2.5'
gem 'ruby-filemagic', '~> 0.7'

gem 'sidekiq', '~> 4.1'
gem 'sidekiq-scheduler', '~> 2.0'
gem 'lograge', '~> 0.5'
gem 'logstash-event', '~> 1.2'
gem 'rack-cors', '~> 1.0.5', require: 'rack/cors'

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
