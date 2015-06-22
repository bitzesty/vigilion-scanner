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
  end

  it "must have key" do
    expect(build(:scan, key: nil)).not_to be_valid
  end

  it "must have account" do
    expect(build(:scan, account: nil)).not_to be_valid
  end

  describe "status" do
    it "contains all possible statuses" do
      expect(build(:scan)).to respond_to(:pending!)
      expect(build(:scan)).to respond_to(:scanning!)
      expect(build(:scan)).to respond_to(:clean!)
      expect(build(:scan)).to respond_to(:infected!)
      expect(build(:scan)).to respond_to(:error!)
      expect(build(:scan)).to respond_to(:unknown!)
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
  end

  context "with a file" do
    let(:file){ OpenStruct.new(read: "file content") }
    let(:scan){ build(:scan, url: nil, file: file) }

    context "on create" do
      it "saves the file" do
        scan.save!
        expect(scan.file_exist?).to eq true
        scan.delete_file
      end
    end

    context "on destroy" do
      before do
        scan.save!
      end

      it "deletes the file" do
        scan.destroy
        expect(scan.file_exist?).to eq false
      end
    end
  end

  describe "#duration" do
    let(:scan){ build(:scan, started_at: 1.hour.ago) }

    it "returns the difference between started_at and ended_at" do
      scan.ended_at = scan.started_at + 300.seconds
      expect(scan.duration).to eq 300
    end
  end
end
