require 'rails_helper'

RSpec.describe "Accounts", type: :request do
  before do
    allow(ENV).to receive(:[]).with("DASHBOARD_API_KEY").and_return("123")
  end

  describe "GET /accounts" do
    it "works! (now write some real specs)" do
      get accounts_path, api_key: "123"
      expect(response).to have_http_status(200)
    end
  end
end
