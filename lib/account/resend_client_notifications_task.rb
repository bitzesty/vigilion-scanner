class Account < ActiveRecord::Base
  has_many :projects, dependent: :destroy

  class ResendClientNotificationsTask
    def initialize(account_id:, date_from:)
      @account = Account.find(account_id)
      @date_from = Date.parse(date_from)
      @projects = @account.projects
    end

    def perform!
      log "re-sending notifications for projects for account #{@account.id} #{@account.name}"
      @projects.each do |project|
        log "notifications for project #{project.name}:"
        project.scans
               .where("created_at > ?", @date_from.beginning_of_day)
               .find_each do |scan|
          log "notifying scan #{scan.id}"
          ClientNotifier.new.notify(scan)
        end
      end
    end

    private

    def log(str)
      puts("[#{Time.now}] #{str}")
      Rails.logger.info("[#{self.class}] #{str}")
    end
  end
end
