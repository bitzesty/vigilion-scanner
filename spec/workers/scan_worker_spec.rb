require 'rails_helper'

RSpec.describe ScanWorker do
  describe "#perform" do
    it "executes ScanService" do
      scan = create :scan
      expect_any_instance_of(ScanService).to receive(:perform).with(scan)
      ScanWorker.new.perform(scan.id)
    end
  end

  describe "integration" do
    context "scan eicar file" do
      it "set scan as infected" do
        scan = create(:scan, file: OpenStruct.new(read: "X5O!P%@AP[4\\PZX54(P^)7CC)7}$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H*"))
        puts scan.id
        ScanWorker.new.perform(scan.id)
        expect(scan.reload).to be_infected
      end
    end

    context "scan regular file" do
      it "set scan as clean" do
        scan = create(:scan, file: OpenStruct.new(read: "regular file"))
        puts scan.id
        ScanWorker.new.perform(scan.id)
        expect(scan.reload).to be_clean
      end
    end
  end
end
