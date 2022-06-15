url = ENV['REDIS_URL'].present? ? ENV['REDIS_URL'] : "redis://redis/0"

Sidekiq.configure_server do |config|
  Rails.logger = Sidekiq::Logging.logger

  config.redis = { url: url }
end

Sidekiq.configure_client do |config|
  config.redis = { url: url }
end
