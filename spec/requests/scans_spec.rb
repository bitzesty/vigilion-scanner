require "rails_helper"

RSpec.describe "Scans", type: :request do
  let(:current_project) { create :project }

  describe "GET /scans" do
    it "works!" do
      allow_any_instance_of(ClientAuthorization).to receive(:valid_hash?).and_return(true)
      get scans_path, {}, "Auth-Key" => current_project.access_key_id
      expect(response).to have_http_status(200)
    end
  end
end
