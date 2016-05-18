source 'https://rubygems.org'

gem 'rails', github: 'rails/rails'
gem 'pg'
gem 'jbuilder', github: 'rails/jbuilder'
gem 'sidekiq'
gem 'sidekiq-unique-jobs'
gem 'typhoeus'
gem 'dotenv-rails'
gem 'puma'
gem 'sentry-raven'

group :development, :test do
  gem 'byebug'
  %w[rails core expectations mocks support].each do |name|
    gem "rspec-#{name}", github: "rspec/rspec-#{name}", branch: 'master'
  end
  gem 'factory_girl_rails'
  gem 'timecop'
  gem 'simplecov', require: false
  gem 'rails-controller-testing'
end
