json.array!(@scans) do |scan|
  json.extract! scan, :response_time, :created_at
end
