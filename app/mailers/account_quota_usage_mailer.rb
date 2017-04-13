class AccountQuotaUsageMailer < ApplicationMailer
  def alert_support(account)
    @account = account
    mail(
      to: "support@vigilion.com",
      subject: "High quota usage for account #{@account.name}"
    )
  end

  def alert_client(account)
    @account = account
    @limit = @account.plan.scans_per_month
    mail(
      to: account.alert_email,
      subject: "Your Vigilion API account #{@account.name} is now over 90%"
    )
  end
end
