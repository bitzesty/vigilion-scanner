require "rails_helper"

RSpec.describe AvRunner do
  describe "#perform" do
    it "sends scanning requests to corrseponding classes" do
      plan = create(:plan, clamav: true, eset: false, avg: false)
      account = create(:account, plan: plan)
      scan = create(:scan, account: account, file: OpenStruct.new(read: "something"))

      clamav = double
      expect(clamav).to receive(:perform!).and_return({})
      expect(AvRunner::Clamav).to receive(:new).with(scan).and_return(clamav)

      described_class.new.perform(scan)

      scan.reload
      expect(scan.mime_type).to eq("text/plain")
      expect(scan.mime_encoding).to eq("charset=us-ascii")
    end

    it "falls back to Marcel when the file command is unavailable" do
      plan = create(:plan, clamav: true, eset: false, avg: false)
      account = create(:account, plan: plan)
      scan = create(:scan, account: account, file: OpenStruct.new(read: "something"))

      clamav = double
      runner = described_class.new
      allow(runner).to receive(:mimetype_from_file_command).and_return(nil)
      expect(clamav).to receive(:perform!).and_return({})
      expect(AvRunner::Clamav).to receive(:new).with(scan).and_return(clamav)

      runner.perform(scan)

      scan.reload
      expect(scan.mime_type).to eq("text/plain")
      expect(scan.mime_encoding).to be_nil
    end

    it "rejects MIME detection paths outside tmp" do
      runner = described_class.new

      expect(runner).not_to receive(:mimetype_from_file_command)
      expect {
        runner.send(:get_mimetype_and_encoding, Rails.root.join("tmp", "..", "evil.txt").to_s)
      }.to raise_error(ArgumentError, "Invalid path")
    end
  end
end
