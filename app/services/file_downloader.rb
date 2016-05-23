class FileDownloader
  MB = 1024 * 1024

  def download(scan)
    scan.file_exists? || download_file(scan)
  rescue DownloadError => error
    scan.complete! :error, "Cannot download file. #{error.message}"
    false
  end

private

  def download_file(scan)
    downloaded_file = File.open scan.file_path, "wb"
    request = Typhoeus::Request.new(scan.url, accept_encoding: "gzip", ssl_verifypeer: false, ssl_verifyhost: 0, followlocation: true)
    request.on_headers do |response|
      validate_status response
      validate_length response, scan.account.plan
    end
    request.on_body do |chunk|
      downloaded_file.write(chunk)
    end
    request.on_complete do
      downloaded_file.close
    end
    request.run
    true
  end

  def validate_status(response)
    if response.code != 200
      raise DownloadError.new "Status: #{response.code}"
    end
  end

  def validate_length(response, plan)
    return unless response.headers["Content-Length"].present?
    if response.headers["Content-Length"].to_i > CONFIG[:max_file_size_mb] * MB
      raise DownloadError.new "File too big"
    end
    unless plan.allow_file_size? response.headers["Content-Length"].to_i
      raise DownloadError.new "File too big for this plan"
    end
  end

  class DownloadError < StandardError
  end
end
