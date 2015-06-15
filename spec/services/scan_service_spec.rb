require 'rails_helper'

RSpec.describe ScanService do
  describe "#perform" do
    before do
      request = Typhoeus::Request.any_instance
      request.should_receive(:on_headers)
      request.should_receive(:on_body).and_yield("something")
      request.should_receive(:on_complete)
      request.stub(:run)
      ENV["AVENGINE"] = "clamscan"
      avscan_response = OpenStruct.new
      avscan_response.value = OpenStruct.new
      avscan_response.value.exitstatus = 0
      stdout = OpenStruct.new
      stdout.read = "Stubbed Result"

      Open3.should_receive(:popen3).and_yield(nil, stdout, nil, avscan_response)
    end

    it "changes scan status" do
      scan = create :scan
      ScanService.new.perform(scan)
      expect(scan).to be_clean
      expect(scan.result).to eq("Stubbed Result")
    end
  end
end