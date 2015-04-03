account = Account.where(name: "test", callback_url: ENV["WEBHOOK_URL"]).first_or_create
puts "X-Auth-Token: #{account.api_key}"
