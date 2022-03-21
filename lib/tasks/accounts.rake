require "account/report_monthly_usage_task"
require "account/resend_client_notifications_task"

namespace :accounts do
  desc "usage: accounts:resend_client_notifications ACCOUNT_ID=3 DATE_FROM=2017-08-07"
  task resend_client_notifications: :environment do
    Account::ResendClientNotificationsTask.new(
      account_id: ENV["ACCOUNT_ID"],
      date_from: ENV["DATE_FROM"]
    ).perform!
  end

  desc "usage: accounts:report_monthly_usage ACCOUNT_ID=8 RECIPIENT=person@example.com"
  task report_monthly_usage: :environment do
    Account::ReportMonthlyUsageTask.new(
      account_id: ENV["ACCOUNT_ID"],
      recipient: ENV["RECIPIENT"]
    ).perform!
  end

  desc "example: accounts:create[1,'demo','https://localhost/vigilion/callback']"
  task :create, [:plan_id, :name, :callback_url] => [:environment] do |_, args|
    plan = Plan.find(args[:plan_id])
    account = Account.create!(plan_id: plan.id)
    project = account.projects.create!(name: args[:name], callback_url: args[:callback_url])
    puts "Created account with plan: #{plan.name} - £#{plan.cost} - #{plan.scans_per_month} scans/mo"
    puts "Project: #{project.name}"
    puts "X-Api-Key: #{project.access_key_id}"
  end
end
