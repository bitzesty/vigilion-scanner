require 'typhoeus'
require 'open3'

class Scan < ActiveRecord::Base
  # STATES
  # scanning - default state after we receive the file
  # clean - no viruses detected
  # infected - viruses detected
  # error - internal error (e.g. file size too large)
  enum status: %w(scanning clean infected error)

  validates :url, presence: true

  def to_s
    "#{status} :: #{id} :: #{url}"
  end

  def virus_check
    # download file to tmp dir
    start_time = Time.now
    download_file

    # take checksums
    md5 = Digest::MD5.file(file_path).hexdigest
    sha1 = Digest::SHA1.file(file_path).hexdigest
    update_attributes(md5: md5, sha1: sha1)

    # scan file with clamav
    clamscan
    # parse results

    # update status
    duration = Time.now - start_time
    puts "Duration: #{duration}"
  end

  def file_path
    @path ||= File.join(File.expand_path('../../..', __FILE__), 'tmp', id)
  end

  def clamscan
    command = EVN["CLAMDSCAN"].present? ? "clamdscan" : "clamscan"

    Open3.popen3("foo", chdir: "/") do |i, o, e, t|
      exit_status = t.value.success?
      p exit_status
      p o.read.chomp
    end
  end

  def download_file
    downloaded_file = File.open file_path, "wb"
    request = Typhoeus::Request.new(url)
    request.on_headers do |response|
      if response.code != 200
        raise "Request failed"
      end
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
end
