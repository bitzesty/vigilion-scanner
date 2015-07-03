require "typhoeus"
require "open3"

class ScanService
  def perform(scan)
    return unless scan.pending?
    scan.start!
    if FileDownloader.new.download scan
      AvRunner.new.perform scan
    end
  ensure
    scan.delete_file
    ClientNotifier.new.notify scan
  end
end
