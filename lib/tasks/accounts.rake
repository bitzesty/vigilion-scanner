namespace :accounts do
  desc "analyse and alert accounts with high quota usage"
  task quota_usage_analyser: :environment do
    AccountQuotaUsageAnalyserService.analyse_all!
  end
end
