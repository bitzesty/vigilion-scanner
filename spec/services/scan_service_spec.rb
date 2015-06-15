require 'rails_helper'

RSpec.describe ScanService do
  describe "#perform" do
    before do
      Typhoeus::Request.any_instance.stub(:run)
    end

    context "with successful download" do
      before do
        mock_download_request
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

    context "with failed download" do
      before do
        mock_download_headers 404
      end

      it "raises an error" do
        scan = create :scan
        expect{ ScanService.new.perform(scan) }.to raise_error("Request failed")
      end
    end
  end

  def mock_download_headers(status = 200)
    request = expect_any_instance_of(Typhoeus::Request)
    response = OpenStruct.new
    response.code = status
    request.to receive(:on_headers).and_yield(response)
    request
  end

  def mock_download_request
    request = mock_download_headers
    request.to receive(:on_body).and_yield("something")
    request.to receive(:on_complete)
  end
end