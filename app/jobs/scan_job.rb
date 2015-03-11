require "active_record"

root_path = File.expand_path("../../..", __FILE__)

config = YAML::load(IO.read(File.join(root_path, "config", "database.yml")))
ActiveRecord::Base.establish_connection(config[ENV["RACK_ENV"] || "development"])
# TODO: Only two files could just maunally require them -.-
Dir.glob(File.join(root_path, "app", "models", "*.rb")).each { |file| require file }
Dir.glob(File.join(root_path, "app", "mappers", "*.rb")).each { |file| require file }

class ScanJob
  include Shoryuken::Worker

  shoryuken_options queue: -> { ENV["SQS_QUEUE"] }, auto_delete: true

  shoryuken_options body_parser: :json

  def perform(_, hash)
    scan = Scan.find(hash['id'])
    scan.virus_check

    # Notify Webhook
    if ENV["WEBHOOK_URL"].present?
      Typhoeus.post(ENV["WEBHOOK_URL"],
                    body: ScanMapping.representation_for(:read, scan),
                    headers: {
                      "Content-Type" => "application/json",
                      "User-Agent" => "VirusScanbot"
                     }
                    )
    end
  end
end
