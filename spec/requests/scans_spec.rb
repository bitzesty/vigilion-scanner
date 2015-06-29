require 'rails_helper'

RSpec.describe "Scans", type: :request do
  let(:current_account) {
    create :account
  }

  describe "GET /scans" do
    it "works!" do
      get scans_path,{} , "Auth-Key" => current_account.access_key_id
      expect(response).to have_http_status(200)
    end
  end
end
