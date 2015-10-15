json.array!(@projects) do |project|
  json.extract! project, :id, :name, :callback_url, :account_id
  json.url project_url(project, format: :json)
end
