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

      context "status OK" do
        before { mock_download_request }

        it { expect(downloader.download(scan)).to be true }

        it "downloads the file" do
          downloader.download(scan)
          expect(file_content(scan)).to eq url_content
        end
      end

      context "status 404" do
        before { mock_download_headers 404 }

        it { expect(downloader.download(scan)).to be false }

        it "sets scan status to error" do
          downloader.download(scan)
          scan.reload
          expect(scan).to be_error
          expect(scan.result).to eq("Cannot download file. Status: 404")
        end
      end

      after do
        scan.destroy
      end
    end

    def mock_download_headers(status = 200)
      request = expect_any_instance_of(Typhoeus::Request)
      response = OpenStruct.new
      response.code = status
      response.headers = { "Content-Length" => 1000 }
      request.to receive(:on_headers).and_yield(response)
      request.to receive(:run)
      request
    end

    def mock_download_request
      request = mock_download_headers
      request.to receive(:on_body).and_yield(url_content)
      request.to receive(:on_complete).and_yield
    end

    def file_content(scan)
      File.open(scan.file_path, "rb").read
    end
  end
end
