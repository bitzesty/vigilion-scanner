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
      before do
        ActionMailer::Base.deliveries.clear
        create_list :scan, 8, project: account_project
      end

      it "one alert is triggered for support" do
        described_class.new(account: account).perform!
        email = ActionMailer::Base.deliveries.last
        expect(ActionMailer::Base.deliveries.count).to eq(1)
        expect(email.to).to eq(%w(support@vigilion.com))
        expect(email.subject).to include(account.name)
        expect(email.body).to include(account_project.name)
      end
    end

    context "when 90% usage is hit" do
      before do
        ActionMailer::Base.deliveries.clear
        create_list :scan, 9, project: account_project
      end

      it "we alert the client **as well**" do
        described_class.new(account: account).perform!
        email = ActionMailer::Base.deliveries.last
        expect(ActionMailer::Base.deliveries.count).to eq(2)
        expect(email.to).to eq([account.alert_email])
        expect(email.subject).to include(account.name)
        expect(email.body).to include(account.name)
        expect(email.body).to include("limit of #{plan.scans_per_month}")
      end
    end
  end
end
