class AccountQuotaUsageAnalyserService
  QUOTA_ALERT = 0.8 # 80%

  def initialize(scan:)
    @scan = scan
    @account = @scan.account
    @plan = @account.plan
  end

  def perform!
    return if unlimited_plan?
    alert_amount = @plan.scans_per_month * QUOTA_ALERT
    if @account.scan_amount_this_month == alert_amount.to_i
      AccountQuotaUsageMailer.alert_support(@scan).deliver_later
    end
  end

  private

  def unlimited_plan?
    @plan.scans_per_month.nil?
  end
end
