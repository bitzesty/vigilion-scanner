require "account/resend_client_notifications_task"

namespace :accounts do
  desc "usage: accounts:resend_client_notifications ACCOUNT_ID=3 DATE_FROM=2017-08-07"
  task resend_client_notifications: :environment do
    Account::ResendClientNotificationsTask.new(
      account_id: ENV["ACCOUNT_ID"],
      date_from: ENV["DATE_FROM"]
    ).perform!
  end
end
