require "open3"

class AvRunner
  def perform(scan)
    set_checksums_and_file_size scan
    unless cache_hit(scan)
      Open3.popen3("#{CONFIG[:av_engine]} #{scan.file_path}") do |_, stdout, _, wait_thr|
        scan.complete! status_from_clamav(wait_thr), message_from_clamav(stdout)
      end
    end
  end

private

  def set_checksums_and_file_size(scan)
    md5 = Digest::MD5.file(scan.file_path).hexdigest
    sha1 = Digest::SHA1.file(scan.file_path).hexdigest
    sha256 = Digest::SHA256.file(scan.file_path).hexdigest
    file_size = File.size(scan.file_path)
    scan.update!(md5: md5, sha1: sha1, sha256: sha256, file_size: file_size)
  end

  def cache_hit(scan)
    return false if scan.force?
    similar_scan = Scan.where(md5: scan.md5).
      where("ended_at > ?", 30.days.ago).
      where("id != ?", scan.id).
      where("status != 4").
      last
    if similar_scan
      scan.complete! similar_scan.status, "CACHE HIT: Similar scan performed"
    end
  end

  def status_from_clamav(wait_thr)
    exit_status = wait_thr.value.exitstatus
    { 0 => :clean, 1 => :infected, 2 => :error }[exit_status]
  end

  def message_from_clamav(stdout)
    first_line = stdout.read.split("\n")[0]
    # Strip filepath out of message
    first_line.gsub(/.*: /im, '')
  end
end
