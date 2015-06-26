require 'rails_helper'

RSpec.describe Account, type: :model do
  it "must have a name" do
    expect(build(:account, name: nil)).not_to be_valid
  end
end
