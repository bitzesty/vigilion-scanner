require 'rails_helper'
require 'open3'

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
        stub_clamav_scan(message: "tmp: Eicar-Test-Signature FOUND", exitstatus: 1)
        scan = create(:scan, file: OpenStruct.new(read: "X5O!P%@AP[4\\PZX54(P^)7CC)7}$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H*"))
        expect_any_instance_of(ClientNotifier).to receive(:notify)
        ScanWorker.new.perform(scan.id)
        expect(scan.reload).to be_clamav_infected
        expect(scan).to be_infected
        expect(scan.result).to eq(scan.clamav_result)
      end
    end

    context "scan regular file" do
      it "set scan as clean" do
        stub_clamav_scan(message: "tmp: OK", exitstatus: 0)
        scan = create(:scan, file: OpenStruct.new(read: "regular file"))
        expect_any_instance_of(ClientNotifier).to receive(:notify)
        ScanWorker.new.perform(scan.id)
        expect(scan.reload).to be_clamav_clean
        expect(scan).to be_clean
        expect(scan.result).to eq(scan.clamav_result)
      end
    end
  end

  def stub_clamav_scan(message:, exitstatus:)
    response = OpenStruct.new(value: OpenStruct.new(exitstatus: exitstatus))
    stdout = OpenStruct.new(read: message)
    allow(Open3).to receive(:popen3).and_yield(nil, stdout, nil, response)
  end
end
