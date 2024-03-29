require 'rails_helper'

RSpec.describe FileDownloader do
  subject(:downloader){ FileDownloader.new }
  let(:url_content) { "downloaded content" }

  describe "#download" do
    context "with an existing file" do
      let(:scan) { create :scan, status: :scanning, file: OpenStruct.new(read: "something") }

      it { expect(downloader.download(scan)).to be true }

      it "doesn't attempt to download the file" do
        expect_any_instance_of(Typhoeus::Request).not_to receive(:run)
        downloader.download(scan)
      end

      after do
        scan.destroy
      end
    end

    context "without an existing file" do
      let(:scan) { create :scan, status: :scanning }

      after do
        scan.destroy
      end

      it "attempt to download the file" do
        expect_any_instance_of(Typhoeus::Request).to receive(:run)
        downloader.download(scan)
      end

      context "status OK" do
        before { mock_download_request }

        it { expect(downloader.download(scan)).to be true }

        it "downloads the file" do
          downloader.download(scan)
          expect(file_content(scan)).to eq url_content
        end
      end

      context "status 404" do
        before { mock_download_request 404 }

        it { expect(downloader.download(scan)).to be false }

        it "sets scan status to error" do
          downloader.download(scan)
          scan.reload
          expect(scan).to be_error
          expect(scan.result).to eq("Cannot download file. Status: 404")
        end
      end

      context "with a file too big" do
        before do
          mock_download_request 200, 100 * 1024 *1024
        end

        it { expect(downloader.download(scan)).to be false }

        it "sets scan status to error" do
          downloader.download(scan)
          scan.reload
          expect(scan).to be_error
          expect(scan.result).to eq("Cannot download file. File too big")
        end
      end

      context "with a file too big for this plan" do
        before do
          mock_download_request 200, 1
          scan.account.plan.update(file_size_limit: 0)
        end

        it { expect(downloader.download(scan)).to be false }

        it "sets scan status to error" do
          downloader.download(scan)
          scan.reload
          expect(scan).to be_error
          expect(scan.result).to eq("Cannot download file. File too big for this plan")
        end
      end

      context "when there is no file header" do
       before do
          mock_download_request 200, nil
        end

        it "downloads the file" do
          downloader.download(scan)
          expect(file_content(scan)).to eq url_content
        end
      end
    end

    def mock_download_request(status = 200, content_length = 1000)
      request = allow_any_instance_of(Typhoeus::Request)
      response = OpenStruct.new
      response.code = status
      response.headers = {}
      response.headers.merge!({ "Content-Length" => content_length.to_s }) if content_length
      request.to receive(:on_headers).and_yield(response)
      request.to receive(:on_body).and_yield(url_content)
      request.to receive(:on_complete).and_yield
      request.to receive(:run)
      request
    end

    def file_content(scan)
      File.open(scan.file_path, "rb").read
    end
  end
end
