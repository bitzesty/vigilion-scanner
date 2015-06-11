class ScanWorker
  include Shoryuken::Worker

  shoryuken_options queue: -> { ENV["SQS_QUEUE"] }, auto_delete: true
  shoryuken_options body_parser: :json

  def perform(_, params)
    scan = Scan.find params["id"]
    ScanService.new.perform scan
  end
end