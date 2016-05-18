class ScanWorker
  include Sidekiq::Worker

  sidekiq_options retry: 2

  def perform(id)
    scan = Scan.find id
    logger.info "Scanning #{id}"
    ScanService.new.perform scan
  end
end
