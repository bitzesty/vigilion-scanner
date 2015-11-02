class ScanWorker
  include Sidekiq::Worker

  sidekiq_options queue: :scan, retry: 2

  def perform(params)
    scan = Scan.find params["id"]
    ScanService.new.perform scan
  end
end
