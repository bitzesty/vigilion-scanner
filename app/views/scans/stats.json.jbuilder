json.array!(@scans) do |scan|
  json.set! :created_at, scan[0]
  json.set! :count, scan[1]
end
