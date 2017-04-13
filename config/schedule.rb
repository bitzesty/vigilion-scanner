every :day, at: '1am' do
  rake "accounts:quota_usage_analyser"
end
