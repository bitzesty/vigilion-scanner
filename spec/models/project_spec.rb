require "rails_helper"

RSpec.describe Project, type: :model do
  it "must have a callback_url" do
    expect(build(:project, callback_url: nil)).not_to be_valid
  end

  describe "#access_key_id" do
    it "must be unique" do
      create(:project).update_attributes(access_key_id: 'repeated')
      second_project = build(:project, access_key_id: 'repeated')
      expect(second_project).not_to be_valid
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
end
