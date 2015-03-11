require "typhoeus"
require "open3"
require "fileutils"

class Scan < ActiveRecord::Base
  # STATES
  # scanning - default state after we receive the file
  # clean - no viruses detected
  # infected - viruses detected
  # error - internal error (e.g. file size too large)
  enum status: %w(scanning clean infected error unknown)

  validates :url, presence: true

  def to_s
    "#{status} :: #{id} :: #{url}"
  end

  def virus_check
    start_time = Time.now
    # download file to tmp dir
    download_file

    # take checksums
    checksums

    # scan file with clamav
    new_status, new_message = clamscan
  ensure
    cleanup
    update!(
      status: new_status,
      message: new_message,
      duration: (Time.now - start_time).ceil
    )
  end

  def file_path
    @path ||= File.join(File.expand_path("../../..", __FILE__), "tmp", id)
  end

  def download_file
    downloaded_file = File.open file_path, "wb"
    request = Typhoeus::Request.new(url, accept_encoding: "gzip")
    request.on_headers do |response|
      raise "Request failed" if response.code != 200
    end
    request.on_body do |chunk|
      downloaded_file.write(chunk)
    end
    request.on_complete do |response|
      downloaded_file.close
      # Note that response.body is ""
    end
    request.run
  end

  def checksums
    md5 = Digest::MD5.file(file_path).hexdigest
    sha1 = Digest::SHA1.file(file_path).hexdigest
    sha256 = Digest::SHA256.file(file_path).hexdigest
    update(md5: md5, sha1: sha1, sha256: sha256)
  end

  def clamscan
    command = ENV["CLAMDSCAN"].present? ? "clamdscan" : "clamscan"
    begin
      Open3.popen3("#{command} #{file_path}") do |stdin, stdout, stderr, wait_thr|
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
  end

  def cleanup
    FileUtils.rm file_path, force: true
  end
end
