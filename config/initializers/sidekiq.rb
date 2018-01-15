url = ENV['REDIS_URL'].present? ? ENV['REDIS_URL'] : "redis://:#{ENV['REDIS_ENV_REDIS_PASSWORD']}@#{ENV['REDIS_PORT_6379_TCP_ADDR']}:#{ENV['REDIS_PORT_6379_TCP_PORT']}/0"

Sidekiq.configure_server do |config|
  Rails.logger = Sidekiq::Logging.logger
  config.logger.formatter = Lograge::Formatters::Logstash.new

  config.redis = { url: url }
end

Sidekiq.configure_client do |config|
  config.redis = { url: url }
end
