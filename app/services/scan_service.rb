require "typhoeus"
require "open3"

class ScanService
  def perform(scan)
    scan.start!
    if FileDownloader.new.download scan
      set_checksums_and_file_size scan
      AvRunner.new.perform scan
    end
  ensure
    scan.delete_file
    notify_client scan
  end

  def set_checksums_and_file_size(scan)
    md5 = Digest::MD5.file(scan.file_path).hexdigest
    sha1 = Digest::SHA1.file(scan.file_path).hexdigest
    sha256 = Digest::SHA256.file(scan.file_path).hexdigest
    file_size = File.size(scan.file_path)
    scan.update!(md5: md5, sha1: sha1, sha256: sha256, file_size: file_size)
  end

  def notify_client(scan)
    account = scan.account
    body = scan.to_json(except: :account_id)
    Typhoeus.post(
      account.callback_url,
      body: body,
      headers: {
        "Content-Type" => "application/json",
        "User-Agent" => "VirusScanbot",
        "Auth-Key" => account.access_key_id,
        "Auth-Hash" => Digest::MD5.hexdigest("#{body}#{account.secret_access_key}")})
  end
end
