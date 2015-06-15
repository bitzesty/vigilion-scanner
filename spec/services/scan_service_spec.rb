require 'rails_helper'

RSpec.describe ScanService do
  describe "#perform" do
    before do
      request = expect_any_instance_of(Typhoeus::Request)
      request.to receive(:on_headers)
      request.to receive(:on_body).and_yield("something")
      request.to receive(:on_complete)
      Typhoeus::Request.any_instance.stub(:run)

      ENV["AVENGINE"] = "clamscan"
      avscan_response = OpenStruct.new
      avscan_response.value = OpenStruct.new
      avscan_response.value.exitstatus = 0
      stdout = OpenStruct.new
      stdout.read = "Stubbed Result"

      expect(Open3).to receive(:popen3).and_yield(nil, stdout, nil, avscan_response)
    end

    it "changes scan status" do
      scan = create :scan
      ScanService.new.perform(scan)
      expect(scan).to be_clean
      expect(scan.result).to eq("Stubbed Result")
    end
  end
end