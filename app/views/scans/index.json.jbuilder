json.array!(@scans) do |scan|
  json.extract! scan, :id, :url, :key, :created_at, :status, :result, :duration, :response_time, :file_size
end
