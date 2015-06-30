require "typhoeus"
require "open3"

class ScanService
  def perform(scan)
    @scan = scan
    @account = scan.account
    @scan.start!
    if @scan.file_exist? || download_file
      set_checksums_and_file_size
      execute_avengine
    end
  ensure
    cleanup
    notify_client
  end

  def download_file
    downloaded_file = File.open @scan.file_path, "wb"
    request = Typhoeus::Request.new(@scan.url, accept_encoding: "gzip")
    request.on_headers do |response|
      if response.code != 200
        @scan.complete! :error, "Cannot download file. Status: #{response.code}"
      end
    end
    request.on_body do |chunk|
      downloaded_file.write(chunk)
    end
    request.on_complete do
      downloaded_file.close
      # Note that response.body is ""
    end
    request.run
    @scan.scanning?
  end

  def set_checksums_and_file_size
    md5 = Digest::MD5.file(@scan.file_path).hexdigest
    sha1 = Digest::SHA1.file(@scan.file_path).hexdigest
    sha256 = Digest::SHA256.file(@scan.file_path).hexdigest
    file_size = File.size(@scan.file_path)
    @scan.update!(md5: md5, sha1: sha1, sha256: sha256, file_size: file_size)
  end

  def execute_avengine
    Open3.popen3("#{CONFIG[:av_engine]} #{@scan.file_path}") do |_, stdout, _, wait_thr|
      new_status = case wait_thr.value.exitstatus
                   when 0
                     :clean
                   when 1
                     :infected
                   else
                     :error
                   end

      first_line = stdout.read.split("\n")[0]
      # Strip filepath out of message
      new_message = first_line.gsub("#{@scan.file_path}: ", "")

      @scan.complete! new_status, new_message
    end
  end

  def cleanup
    @scan.delete_file
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
