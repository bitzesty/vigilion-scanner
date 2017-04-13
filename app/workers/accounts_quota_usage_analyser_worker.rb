class AccountsQuotaUsageAnalyserWorker
  include Sidekiq::Worker

  def perform
    AccountQuotaUsageAnalyserService.analyse_all!
  end
end
