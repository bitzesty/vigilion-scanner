require "rails_helper"

RSpec.describe AccountQuotaUsageAnalyserService do
  describe "alerts on high quota usage" do
    let(:plan) { create :plan, scans_per_month: 10 }
    let(:account) { create :account, plan: plan }
    let(:account_project){ create :project, account: account }

    context "below 80% usage" do
      before { create_list :scan, 6, project: account_project }

      it "no alerts are triggered" do
        expect(AccountQuotaUsageMailer).not_to receive(:alert_support)
        described_class.new(account: account).perform!
      end
    end

    context "when 80% usage is hit" do
      before { create_list :scan, 8, project: account_project }

      it "an alert is triggered" do
        described_class.new(account: account).perform!
        email = ActionMailer::Base.deliveries.last
        expect(email.subject).to include(account.id.to_s)
        expect(email.body).to include(account_project.name)
      end
    end
  end
end
