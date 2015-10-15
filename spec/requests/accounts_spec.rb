require 'rails_helper'

RSpec.describe "Accounts", type: :request do
  let(:account) { create :account }

  describe "GET /accounts/ID" do
    it "works!" do
      get account_path(account), {}, "Dashboard-Auth-Key" => CONFIG["dashboard_api_key"]
      expect(response).to have_http_status(200)
    end
  end
end
