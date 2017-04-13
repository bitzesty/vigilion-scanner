class AccountQuotaUsageAnalyserService
  class << self
    def analyse_all!
      Account.find_each do |account|
        new(account: account).perform!
      end
    end
  end

  QUOTA_ALERT = 0.8 # 80%

  def initialize(account:)
    @account = account
    @plan = @account.plan
  end

  def perform!
    return if unlimited_plan?
    alert_amount = @plan.scans_per_month * QUOTA_ALERT
    if @account.scan_amount_this_month >= alert_amount.to_i
      AccountQuotaUsageMailer.alert_support(@account).deliver_later
    end
  end

  private

  def unlimited_plan?
    @plan.scans_per_month.nil?
  end
end
