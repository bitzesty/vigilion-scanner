require 'rails_helper'

RSpec.describe ScanService do
  describe "#perform" do
    before do
      Typhoeus::Request.any_instance.stub(:run)
    end

    context "with an existing file" do
      before do
        mock_avscan
      end

      let(:scan) { create :scan, file: OpenStruct.new(read: "something") }

      it "works without downloading" do
        ScanService.new.perform(scan)
        expect(scan).to be_clean
      end

      it "deletes the file after scanning" do
        ScanService.new.perform(scan)
        expect(scan.file_exist?).to eq false
      end
    end

    context "with successful download" do
      before do
        mock_download_request
        mock_avscan
      end

      let(:scan){ create :scan }

      it "changes scan status" do
        ScanService.new.perform(scan)
        expect(scan).to be_clean
        expect(scan.result).to eq("Stubbed Result")
      end

      it "deletes the file after scanning" do
        ScanService.new.perform(scan)
        expect(scan.file_exist?).to eq false
      end
    end

    context "with failed download" do
      before do
        mock_download_headers 404
      end

      it "raises an error" do
        scan = create :scan
        ScanService.new.perform(scan)
        scan.reload
        expect(scan).to be_error
        expect(scan.result).to eq("Cannot download file. Status: 404")
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

  def mock_avscan
    avscan_response = OpenStruct.new
    avscan_response.value = OpenStruct.new
    avscan_response.value.exitstatus = 0
    stdout = OpenStruct.new
    stdout.read = "Stubbed Result"
    expect(Open3).to receive(:popen3).and_yield(nil, stdout, nil, avscan_response)
  end
end