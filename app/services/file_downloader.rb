class FileDownloader
  MB = 1024 * 1024

  def download(scan)
    scan.file_exists? || download_file(scan)
  end

private

  def download_file(scan)
    downloaded_file = File.open scan.file_path, "wb"
    request = Typhoeus::Request.new(scan.url, accept_encoding: "gzip")
    request.on_headers do |response|
      if response.code != 200
        scan.complete! :error, "Cannot download file. Status: #{response.code}"
      end
      if response.headers["Content-Length"] > CONFIG[:max_file_size_mb] * MB
        scan.complete! :error, "Cannot download file. File too big"
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
    scan.scanning?
  end
end