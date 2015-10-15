require 'rails_helper'

RSpec.describe Plan, type: :model do
  describe "#allow_more_scans?" do
    context "with no scans limit" do
      let(:plan) { create(:plan, :no_scans_limit) }

      it { expect(plan.allow_more_scans?(1000000)).to eq true }
    end

    context "with 10 scans_per_month" do
      let(:plan) { create(:plan, scans_per_month: 10) }

      it { expect(plan.allow_more_scans?(9)).to  eq true }
      it { expect(plan.allow_more_scans?(10)).to eq false }
      it { expect(plan.allow_more_scans?(11)).to eq false }
    end
  end

  describe "#allow_file_size?" do
    context "with a limitless plan" do
      let(:plan) { create(:plan, :no_size_limit) }

      it { expect(plan.allow_file_size?(1000000)).to eq true }
    end

    context "with 1MB limit" do
      let(:plan) { create(:plan, file_size_limit: 1) }

      it { expect(plan.allow_file_size?(1024 * 1024)).to eq true }
      it { expect(plan.allow_file_size?(1024 * 1024 + 1)).to eq false }
    end
  end
end
