require 'rails_helper'

RSpec.describe Scan, type: :model do

  describe "#url" do
    it "must be absolute" do
      expect(build(:scan, url: "/some/path.zip")).not_to be_valid
    end

    context "without a supplementary file" do
      it "cannot be nil on create" do
        expect(build(:scan, url: nil, file: nil)).not_to be_valid
      end

      it "can be nil on update" do
        scan = create(:scan, file: nil)
        scan.url = nil
        expect(scan).to be_valid
      end
    end

    context "with a supplementary file" do
      it "can be nil" do
        expect(build(:scan, url: nil, file: "this is a file")).to be_valid
      end
    end

    it "can be http or https" do
      expect(build(:scan, url: "http://domain/file.zip")).to be_valid
      expect(build(:scan, url: "https://domain/file.zip")).to be_valid
    end

    context "do_not_unencode?" do
      it "does not unescape url" do
        expect(Addressable::URI).to_not receive(:unescape)
        url = "https://domain/file.txt?Signature=ZWY%3D%0A"
        scan = create(:scan, do_not_unencode: true, url: url)
        expect(scan.url).to eq(url)
      end

      it "unescapes url" do
        url = "https://domain/file.txt?Signature=ZWY%3D%0A"
        expect(Addressable::URI).to receive(:unescape).with(url).at_least(:once)
        scan = create(:scan, do_not_unencode: false, url: url)
        expect(
          scan.url
        ).to eq(Addressable::URI.unescape(url))
      end
    end
  end

  it "must have key" do
    expect(build(:scan, key: nil)).not_to be_valid
  end

  it "must have project" do
    expect(build(:scan, project: nil)).not_to be_valid
  end

  describe "status" do
    it "contains all possible statuses" do
      expect(build(:scan)).to respond_to(:pending!)
      expect(build(:scan)).to respond_to(:scanning!)
      expect(build(:scan)).to respond_to(:clean!)
      expect(build(:scan)).to respond_to(:infected!)
      expect(build(:scan)).to respond_to(:error!)
    end

    it "defaults to pending" do
      expect(create(:scan)).to be_pending
    end
  end

  describe "#file_path" do
    it "must contain id" do
      scan = create(:scan)
      expect(scan.file_path).to match /#{scan.id}/
    end

    context "do_not_unencode?" do
      it "unescaping url" do
        url = "https://domain/file.txt?Signature=ZWY%3D%0A"
        scan = create(:scan, do_not_unencode: false, url: url)
        expect(scan.file_path).to end_with(".txt")
      end

      it "skipping unescaping url" do
        url = "https://domain/file.txt?Signature=ZWY%3D%0A"
        scan = create(:scan, do_not_unencode: true, url: url)
        expect(scan.file_path).to end_with(".txt")
      end
    end
  end

  context "with a file" do
    let(:file){ OpenStruct.new(read: "file content") }
    let(:scan){ build(:scan, url: nil, file: file) }

    context "on create" do
      it "saves the file" do
        scan.save!
        expect(scan.file_exists?).to eq true
        scan.delete_file
      end
    end

    context "on destroy" do
      before do
        scan.save!
      end

      it "deletes the file" do
        scan.destroy
        expect(scan.file_exists?).to eq false
      end
    end
  end

  describe "#duration" do
    context "when the scan was completed" do
      it "returns the difference between started_at and ended_at" do
        scan = build(:scan, started_at: 1.hour.ago)
        scan.ended_at = scan.started_at + 300.seconds
        expect(scan.duration).to eq 300
      end
    end

    context "before the scanning process has started" do
      it "returns nil" do
        scan = build(:scan, started_at: nil, ended_at: nil)
        expect(scan.duration).to eq nil
      end
    end

    context "before the scanning process has ended" do
      it "returns nil" do
        scan = build(:scan, started_at: 1.hour.ago, ended_at: nil)
        expect(scan.duration).to eq nil
      end
    end
  end

  describe "#response_time" do
    context "when the scan was completed" do
      it "returns the difference between created_at and ended_at" do
        scan = build(:scan, created_at: 1.hour.ago)
        scan.ended_at = scan.created_at + 300.seconds
        expect(scan.response_time).to eq 300
      end
    end

    context "before the scanning process has ended" do
      it "returns nil" do
        scan = build(:scan, created_at: 1.hour.ago, ended_at: nil)
        expect(scan.response_time).to eq nil
      end
    end
  end

  describe "#start!" do
    it "sets started_at and status" do
      Timecop.freeze Time.now
      scan = build(:scan, started_at: nil, status: :pending)
      scan.start!
      expect(scan).to be_scanning
      expect(scan.started_at).to eq Time.now
    end
  end

  describe "#complete!" do
    it "sets started_at and status" do
      Timecop.freeze Time.now
      scan = build(:scan, ended_at: nil, status: :pending)
      scan.complete!(:clean, "good")

      expect(scan).to be_clean
      expect(scan.result).to eq "good"
      expect(scan.ended_at).to eq Time.now
    end
  end

  describe "#av_checked!" do
    it "sets av status and main status to success" do
      Timecop.freeze Time.now
      scan = build(:scan, ended_at: nil, status: :pending)
      scan.av_checked!(
        clamav: {
          status: :clean,
          message: "good"
        }
      )

      expect(scan).to be_clean
      expect(scan.result).to eq "good"
      expect(scan).to be_clamav_clean
      expect(scan.clamav_result).to eq "good"
      expect(scan.ended_at).to eq Time.now
    end

    it "sets av status and main status to failure" do
      Timecop.freeze Time.now
      scan = build(:scan, ended_at: nil, status: :pending)
      scan.av_checked!(
        clamav: {
          status: :clean,
          message: "good"
        },
        avg: {
          status: :infected,
          message: "wrong"
        }
      )

      expect(scan).to be_infected
      expect(scan.result).to eq "wrong"
      expect(scan).to be_avg_infected
      expect(scan.avg_result).to eq "wrong"
    end
  end

  describe "#engines" do
    it "set's engines accordint to plan" do
      scan = create(:scan)
      expect(scan.reload.engines).to eq([:clamav])
    end

    it "set's engines accordint to plan" do
      plan = create(:plan, clamav: false, eset: true, avg: true)
      account = create(:account, plan: plan)
      scan = create(:scan, account: account)

      expect(scan.reload.engines).to eq([:eset, :avg])
    end
  end

  describe "#relevant_result" do
    it "returns clean if others errored" do
      scan = build(:scan)
      scan_results = {
        clamav: { status: :clean },
        avg: { status: :error }
      }
      expect(
        scan.send(:relevant_result, scan_results)
      ).to eq(scan_results[:clamav])
    end

    it "returns infection if any is infected" do
      scan = build(:scan)
      scan_results = {
        clamav: { status: :clean },
        avg: { status: :infected }
      }
      expect(
        scan.send(:relevant_result, scan_results)
      ).to eq(scan_results[:avg])
    end
  end
end
