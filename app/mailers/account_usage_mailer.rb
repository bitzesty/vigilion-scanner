class AccountUsageMailer < ApplicationMailer
  def monthly_usage(recipient, csv)
    attachments['account_monthly.csv'] = {
      content: csv,
      mime_type: 'text/csv'
    }
    mail(
      to: recipient,
      subject: 'Monthly usage summary',
      body: 'Find your summary attached'
    )
  end
end
