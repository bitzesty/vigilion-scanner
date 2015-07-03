require 'rails_helper'

RSpec.describe ScanService do
  subject(:scan_service){ ScanService.new }

  describe "#perform" do
    context "with pending scan" do
      let(:scan) { create :scan, status: :pending }

      before do
        allow_any_instance_of(FileDownloader).to receive(:download)
        allow_any_instance_of(AvRunner).to receive(:perform)
        allow_any_instance_of(ClientNotifier).to receive(:notify)
      end

      it "starts the scan" do
        expect(scan).to receive(:start!)
        scan_service.perform scan
      end

      it "downloads the file" do
        expect_any_instance_of(FileDownloader).to receive(:download).with(instance_of(Scan))
        scan_service.perform scan
      end

      it "deletes the file" do
        expect(scan).to receive(:delete_file)
        scan_service.perform scan
      end

      it "calls ClientNotifier" do
        expect_any_instance_of(ClientNotifier).to receive(:notify).with(instance_of(Scan))
        scan_service.perform scan
      end

      context "with successful download" do
        before do
          allow_any_instance_of(FileDownloader).to receive(:download).and_return(true)
        end

        it "calls AvRunner" do
          expect_any_instance_of(AvRunner).to receive(:perform).with(instance_of(Scan))
          scan_service.perform scan
        end
      end

      context "with failed download" do
        before do
          allow_any_instance_of(FileDownloader).to receive(:download).and_return(false)
        end

        it "does not call AvRunner" do
          expect_any_instance_of(AvRunner).not_to receive(:perform).with(instance_of(Scan))
          scan_service.perform scan
        end
      end
    end

    context "with non pending scan" do
      let!(:scan) { create :scan, status: :clean }

      it "does nothing" do
        expect_any_instance_of(FileDownloader).not_to receive(:download)
        expect_any_instance_of(ClientNotifier).not_to receive(:notify)
        expect_any_instance_of(AvRunner).not_to receive(:perform)
        scan_service.perform(scan)
      end
    end
  end
end
