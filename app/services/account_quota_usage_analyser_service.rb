class AccountQuotaUsageAnalyserService
  class << self
    def analyse_all!
      Account.find_each do |account|
        new(account: account).perform!
      end
    end
  end

  QUOTA_CLIENT_ALERT = 0.9 # 90%
  QUOTA_SUPPORT_ALERT = 0.8 # 80%

  def initialize(account:)
    @account = account
    @plan = @account.plan
  end

  def perform!
    return if unlimited_plan?
    alert_support!
    alert_client!
  end

  private

  def alert_support!
    support_alert_amount = @plan.scans_per_month * QUOTA_SUPPORT_ALERT
    if @account.scan_amount_this_month >= support_alert_amount.to_i
      AccountQuotaUsageMailer.alert_support(@account).deliver_later
    end
  end

  def alert_client!
    return if @account.alert_email.blank?
    client_alert_amount = @plan.scans_per_month * QUOTA_CLIENT_ALERT
    if @account.scan_amount_this_month >= client_alert_amount.to_i
      AccountQuotaUsageMailer.alert_client(@account).deliver_later
    end
  end

  def unlimited_plan?
    @plan.scans_per_month.nil?
  end
end
