$: << File.expand_path(File.join(File.dirname(__FILE__), '..'))
ENV['RACK_ENV'] = 'test'
ENV['AVENGINE'] ||= 'clamscan'

require 'config/environment'
require 'service'
require 'database_cleaner'

Airborne.configure do |config|
  config.rack_app = Service::App
  # config.headers = {'x-auth-token' => 'my_token'}
end

RSpec.configure do |config|

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

end
