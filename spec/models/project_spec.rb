require "rails_helper"

RSpec.describe Project, type: :model do
  describe "#account" do
    it "must be present" do
      expect(build(:project, account: nil)).not_to be_valid
    end
  end

  describe "#name" do
    it "must be present" do
      expect(build(:project, name: nil)).not_to be_valid
    end
  end

  describe "#callback_url" do
    it "must be present" do
      expect(build(:project, callback_url: nil)).not_to be_valid
    end

    it "must be absolute" do
      expect(build(:project, callback_url: "/some/path.zip")).not_to be_valid
    end
  end

  context "after created" do
    it "has access_keys" do
      project = build(:project, access_key_id: nil, secret_access_key: nil)
      project.save!
      expect(project.access_key_id).to be_present
      expect(project.secret_access_key).to be_present
    end
  end

  describe "#destroy" do
    it "cascade deletes its scans" do
      project = create :project
      create :scan, project: project
      expect{ project.destroy }.to change{ Scan.count }.by -1
    end
  end
end
