require "typhoeus"
require "open3"
require "fileutils"

class ScanService
  def perform(scan)
    @scan = scan
    @account = scan.account
    @scan.update_columns(started_at: Time.now, status: :scanning)

    download_file
    set_checksums
    execute_avengine
  ensure
    cleanup
    notify_client
  end

  def file_path
    @path ||= File.join(File.expand_path("../../..", __FILE__), "tmp", @scan.id)
  end

  def download_file
    downloaded_file = File.open file_path, "wb"
    request = Typhoeus::Request.new(@scan.url, accept_encoding: "gzip")
    request.on_headers do |response|
      raise "Request failed" if response.code != 200
    end
    request.on_body do |chunk|
      downloaded_file.write(chunk)
    end
    request.on_complete do
      downloaded_file.close
      # Note that response.body is ""
    end
    request.run
  end

  def set_checksums
    md5 = Digest::MD5.file(file_path).hexdigest
    sha1 = Digest::SHA1.file(file_path).hexdigest
    sha256 = Digest::SHA256.file(file_path).hexdigest
    @scan.update!(md5: md5, sha1: sha1, sha256: sha256)
  end

  def execute_avengine
    Open3.popen3("#{CONFIG[:av_engine]} #{file_path}") do |_, stdout, _, wait_thr|
      new_status = case wait_thr.value.exitstatus
                   when 0
                     :clean
                   when 1
                     :infected
                   when 2
                     :error
                   else
                     :unknown
                   end

      first_line = stdout.read.split("\n")[0]
      # Strip filepath out of message
      new_message = first_line.gsub("#{file_path}: ", "")

      @scan.update!(
        status: new_status,
        result: new_message,
        ended_at: Time.now)
    end
  end

  def cleanup
    FileUtils.rm file_path, force: true
  end

  def notify_client
    body = @scan.to_json(except: :account_id)
    Typhoeus.post(
      @account.callback_url,
      body: body,
      headers: {
        "Content-Type" => "application/json",
        "User-Agent" => "VirusScanbot",
        "Auth-Key" => @account.access_key_id,
        "Auth-Hash" => Digest::MD5.hexdigest("#{body}#{@account.secret_access_key}")})
  end
end
