require "rails_helper"

RSpec.describe AvRunner do
  describe "#perform" do
    it "sends scanning requests to corrseponding classes" do
      plan = create(:plan, clamav: true, eset: false, avg: false)
      account = create(:account, plan: plan)
      scan = create(:scan, account: account, file: OpenStruct.new(read: "something"))

      clamav = double
      expect(clamav).to receive(:perform!).and_return({})
      expect(AvRunner::Clamav).to receive(:new).with(scan).and_return(clamav)

      described_class.new.perform(scan)
    end
  end
end
