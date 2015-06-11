require 'rails_helper'

RSpec.describe "Scans", type: :request do
  describe "GET /scans" do
    it "works! (now write some real specs)" do
      get scans_path
      expect(response).to have_http_status(200)
    end
  end
end
