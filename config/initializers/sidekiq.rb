url = ENV['REDIS_URL'].present? ? ENV['REDIS_URL'] : "redis://:#{ENV['REDIS_ENV_LINK_PASSWORD']}@#{ENV['REDIS_PORT_6379_TCP_ADDR']}:#{ENV['REDIS_PORT_6379_TCP_PORT']}/0"

Sidekiq.configure_server do |config|
  config.redis = { url: url }
end

Sidekiq.configure_client do |config|
  config.redis = { url: url }
end
