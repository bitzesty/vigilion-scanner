require "rails_helper"

RSpec.describe KeysController, type: :request do
  let(:current_project) { create :project }

  describe "POST /rotate" do
    it "renews keys" do
      post keys_rotate_path,
           headers: { 'X-Api-Key' => current_project.access_key_id }
      json = JSON.parse(response.body)
      expect(json["access_key_id"]).to be_present
      expect(json["access_key_id"]).to_not eq(current_project.access_key_id)
      expect(json["secret_access_key"]).to be_present
    end
  end
end
