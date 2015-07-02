require 'rails_helper'

RSpec.describe ScanService do
  describe "#perform" do
    before do
      expect_any_instance_of(Typhoeus::Request).not_to receive(:run)
      expect(Typhoeus).to receive(:post)
    end

    context "with successful download" do
      before do
        allow_any_instance_of(FileDownloader).to receive(:download) { true }
        mock_avscan
      end

      let(:scan) { create :scan, file: OpenStruct.new(read: "something") }

      it "changes scan status" do
        ScanService.new.perform(scan)
        expect(scan).to be_clean
        expect(scan.result).to eq("Stubbed Result")
      end

      it "deletes the file after scanning" do
        ScanService.new.perform(scan)
        expect(scan.file_exists?).to eq false
      end

      context "performing a new scan over the same file" do
        before do
          ScanService.new.perform(scan)
        end

        it "avoids scanning twice" do
          expect(Open3).not_to receive(:popen3)
          expect(Typhoeus).to receive(:post)
          ScanService.new.perform(create(:scan, file: scan.file))
          expect(scan).to be_clean
        end
      end
    end

    context "with failed download" do
      before do
        allow_any_instance_of(FileDownloader).to receive(:download) { false }
      end

      it "avoids scan" do
        expect(Open3).not_to receive(:popen3)
        scan = create :scan
        ScanService.new.perform(scan)
      end
    end

    context "scanning the same scan model again" do
      let!(:scan) { create :scan, status: :clean }

      it "does nothing" do
        expect(Open3).not_to receive(:popen3)
        expect(Typhoeus).not_to receive(:post)
        expect(scan).not_to receive(:save!)
        ScanService.new.perform(scan)
      end
    end
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
