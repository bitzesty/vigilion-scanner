json.array!(@scans) do |scan|
  json.extract! scan, :file_size
  json.created_at scan.date_trunc_minute_created_at
end
