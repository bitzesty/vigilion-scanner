json.array!(@scans) do |scan|
  json.extract! scan, :id, :url, :key
  json.url scan_url(scan, format: :json)
end
