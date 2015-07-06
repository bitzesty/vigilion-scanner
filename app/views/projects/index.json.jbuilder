json.array!(@projects) do |project|
  json.extract! project, :id, :name, :callback_url, :access_key_id, :secret_access_key, :account_id, :heroku_id, :plan, :region, :app
  json.url project_url(project, format: :json)
end
