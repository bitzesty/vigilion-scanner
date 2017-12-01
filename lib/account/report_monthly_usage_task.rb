require "csv"

class Account < ActiveRecord::Base
  class ReportMonthlyUsageTask
    def initialize(account_id:, recipient:)
      @account = Account.find(account_id)
      @recipient = recipient
    end

    def perform!
      AccountUsageMailer.monthly_usage(@recipient, csv).deliver_now
    end

    def csv
      CSV.generate do |csv|
        csv << headers
        @account.projects.each do |project|
          csv << row_for(project)
        end
      end
    end

    def headers
      months_str = months.map { |month| month.strftime("%b %Y") }
      [ "project / number of scans per month" ].concat(months_str)
    end

    def months
      time_range = @account.created_at.to_date..Date.today
      months = time_range.map(&:beginning_of_month).uniq
    end

    def row_for(project)
      month_values = months.map do |month|
        project.scans.where(created_at: month.beginning_of_month..month.end_of_month).count
      end
      [ project.name ].concat(month_values)
    end
  end
end
