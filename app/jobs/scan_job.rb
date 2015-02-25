require 'active_record'

root_path = File.expand_path('../../..', __FILE__)

config = YAML::load(IO.read(File.join(root_path,'config', 'database.yml')))
ActiveRecord::Base.establish_connection(config[ENV['RACK_ENV'] || 'development'])
Dir.glob(File.join(root_path, 'app', 'models', '*.rb')).each { |file| require file }

class ScanJob
  include Shoryuken::Worker

  shoryuken_options queue: -> { "#{ ENV['SQS_QUEUE'] }" }, auto_delete: true

  shoryuken_options body_parser: :json

  def perform(_, hash)
    scan = Scan.find(hash['id'])
    puts scan.to_s

    scan.virus_check
  end
end
