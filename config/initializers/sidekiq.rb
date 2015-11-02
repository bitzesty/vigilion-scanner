Sidekiq.configure_client do |config|
  config.redis = { namespace: 'vigilion' }
end
Sidekiq.configure_server do |config|
  config.redis = { namespace: 'vigilion' }
end
