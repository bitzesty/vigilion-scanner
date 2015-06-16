require 'rails_helper'

RSpec.describe Account, type: :model do
  it "must have a name" do
    expect(build(:account, name: nil)).not_to be_valid
  end

  it "must have a callback_url" do
    expect(build(:account, callback_url: nil)).not_to be_valid
  end

  describe "#access_key_id" do
    it "must be unique" do
      create(:account).update_attributes(access_key_id: 'repeated')
      second_account = build(:account, access_key_id: 'repeated')
      expect(second_account).not_to be_valid
    end
  end

  context "after created" do
    it "has access_keys" do
      account = build(:account, access_key_id: nil, secret_access_key: nil)
      account.save!
      expect(account.access_key_id).to be_present
      expect(account.secret_access_key).to be_present
    end
  end
end
