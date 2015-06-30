class AvRunner
  def perform(scan)
    unless cache_hit(scan)
      Open3.popen3("#{CONFIG[:av_engine]} #{scan.file_path}") do |_, stdout, _, wait_thr|
        scan.complete! status_from_clamav(wait_thr), message_from_clamav(stdout)
      end
    end
  end

private

  def cache_hit(scan)
    similar_scan = Scan.where(md5: scan.md5).
      where("ended_at > ?", 24.hours.ago).
      where("id != ?", scan.id).
      last
    if similar_scan
      scan.complete! similar_scan.status, "CACHE HIT: Similar scan performed"
    end
  end

  def status_from_clamav(wait_thr)
    case wait_thr.value.exitstatus
    when 0
      :clean
    when 1
      :infected
    else
      :error
    end
  end

  def message_from_clamav(stdout)
      first_line = stdout.read.split("\n")[0]
      # Strip filepath out of message
      first_line.gsub(/.*: /im, "")
  end
end