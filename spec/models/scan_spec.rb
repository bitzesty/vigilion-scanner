require 'rails_helper'

RSpec.describe Scan, type: :model do

  describe "#url" do
    it "must be present" do
      expect(build(:scan, url: nil)).not_to be_valid
    end

    it "must be absolute" do
      expect(build(:scan, url: "/some/path.zip")).not_to be_valid
    end

    it "can be http or https" do
      expect(build(:scan, url: "http://domain/file.zip")).to be_valid
      expect(build(:scan, url: "https://domain/file.zip")).to be_valid
    end
  end

  describe "#key" do
    it "must be present" do
      expect(build(:scan, key: nil)).not_to be_valid
    end
  end

  describe "status" do
    it "contains all possible statuses" do
      expect(build(:scan)).to respond_to(:pending!)
      expect(build(:scan)).to respond_to(:clean!)
      expect(build(:scan)).to respond_to(:infected!)
      expect(build(:scan)).to respond_to(:error!)
      expect(build(:scan)).to respond_to(:unknown!)
    end

    it "defaults to pending" do
      expect(create(:scan)).to be_pending
    end
  end
end
