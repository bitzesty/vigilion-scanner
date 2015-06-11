json.array!(@accounts) do |account|
  json.extract! account, :id, :name, :callback_url, :access_key_id, :encrypted_secret_access_key
  json.url account_url(account, format: :json)
end
