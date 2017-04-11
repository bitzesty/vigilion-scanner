class AccountQuotaUsageMailer < ApplicationMailer
  def alert_support(scan)
    @project = scan.project
    mail(
      to: "support@vigilion.com",
      subject: "High quota usage for #{@project.name}"
    )
  end
end
