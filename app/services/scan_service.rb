require "typhoeus"
require "open3"
require "fileutils"

class ScanService

  def perform scan
    @scan = scan
    @account = scan.account

    start_time = Time.now
    # download file to tmp dir
    download_file

    # take checksums
    checksums

    # scan file with clamav
    new_status, new_message = avscan


    # Notify Webhook
    if @account.callback_url.present?
      Typhoeus.post(@account.callback_url,
                    body: ScanMapping.representation_for(:read, scan),
                    headers: {
                      "Content-Type" => "application/json",
                      "User-Agent" => "VirusScanbot"
                    }
                    )
    end
  ensure
    cleanup
    @scan.update!(
      status: new_status,
      result: new_message,
      duration: (Time.now - start_time).ceil
    )
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

  def checksums
    md5 = Digest::MD5.file(file_path).hexdigest
    sha1 = Digest::SHA1.file(file_path).hexdigest
    sha256 = Digest::SHA256.file(file_path).hexdigest
    @scan.update!(md5: md5, sha1: sha1, sha256: sha256)
  end

  def avscan
    command = ENV["AVENGINE"]
    if ["clamscan", "clamdscan"].include?(ENV["AVENGINE"])
      begin
        Open3.popen3("#{command} #{file_path}") do |_stdin, stdout, _stderr, wait_thr|
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
          return new_status, new_message
        end
      end
    else
      raise ArgumentError, "Invalid AVENGINE"
    end
  end

  def cleanup
    FileUtils.rm file_path, force: true
  end
end
