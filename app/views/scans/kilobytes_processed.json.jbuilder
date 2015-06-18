json.array!(@scans) do |scan|
  json.extract! scan, :file_size, :created_at
end
