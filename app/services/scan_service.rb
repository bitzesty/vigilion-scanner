class ScanService
  def perform(scan)
    return unless scan.pending?
    begin
      scan.start!
      if FileDownloader.new.download scan
        AvRunner.new.perform scan
      end
    rescue => ex
      Sidekiq.logger.error ex
      Sidekiq.logger.error ex.backtrace.join("\n")
    ensure
      scan.delete_file
      ClientNotifier.new.notify scan
    end
  end
end
