json.array!(@plans) do |plan|
  json.extract! plan, :id, :name, :cost, :file_size_limit, :scans_per_month
end
