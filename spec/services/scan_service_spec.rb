require 'rails_helper'

RSpec.describe ScanService do
  describe "#perform" do
    it "executes ScanService" do
      request = Typhoeus::Request.any_instance
      request.should_receive(:on_headers)
      request.should_receive(:on_body)
      request.should_receive(:on_complete)
      request.stub(:run)
      ENV["AVENGINE"] = "clamscan"
      Open3.should_receive(:popen3)

      scan = create :scan
      ScanService.new.perform(scan)
    end
  end
end