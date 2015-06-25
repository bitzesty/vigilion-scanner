json.array!(@scans) do |scan|
  json.extract! scan, :id, :created_at, :status, :duration, :response_time, :file_size
end
