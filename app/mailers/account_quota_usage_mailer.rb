class AccountQuotaUsageMailer < ApplicationMailer
  def alert_support(account)
    @account = account
    mail(
      to: "support@vigilion.com",
      subject: "High quota usage for account #{@account.id}"
    )
  end
end
