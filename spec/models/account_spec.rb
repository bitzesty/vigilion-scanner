require 'rails_helper'

RSpec.describe Account, type: :model do
  describe "#plan" do
    it "must be present" do
      expect(build(:account, plan: nil)).not_to be_valid
    end
  end

  describe "#scan_amount_this_month" do
    let(:account){ create :account }
    let(:account_project){ create :project, account: account }

    context "2 scans this month" do
      before { create_list :scan, 2, project: account_project }
      it { expect(account.scan_amount_this_month).to eq 2 }
    end

    context "2 scans last month" do
      before { create_list :scan, 2, project: account_project, created_at: 1.month.ago }
      it { expect(account.scan_amount_this_month).to eq 0 }
    end
  end

  describe "allow_more_scans?" do
    let(:plan){ create :plan }
    let(:account){ create :account, plan: plan }

    it "delegates to the plan" do
      expect(account).to receive(:scan_amount_this_month).and_return(123)
      expect(plan).to receive(:allow_more_scans?).with(123).and_return(false)
      expect(account.allow_more_scans?).to be false
    end
  end

  describe "#destroy" do
    it "cascade deletes its projects" do
      account = create :account
      project = create :project, account: account
      expect{ account.destroy }.to change{ Project.count }.by -1
    end

    it "cascade deletes its scans" do
      account = create :account
      project = create :project, account: account
      create :scan, project: project
      expect{ account.destroy }.to change{ Scan.count }.by -1
    end
  end

  describe "alerts on high quota usage" do
    let(:plan) { create :plan, scans_per_month: 10 }
    let(:account) { create :account, plan: plan }
    let(:account_project){ create :project, account: account }

    context "below 80% usage" do
      before { create_list :scan, 6, project: account_project }

      it "no alerts are triggered" do
        expect(AccountQuotaUsageMailer).not_to receive(:alert_support)
        create :scan, project: account_project
      end
    end

    context "when 80% usage is hit" do
      before { create_list :scan, 7, project: account_project }

      it "an alert is triggered" do
        create :scan, project: account_project
        email = ActionMailer::Base.deliveries.last
        expect(email.subject).to include(account_project.name)
        expect(email.body).to include(account_project.name)
      end
    end
  end
end
