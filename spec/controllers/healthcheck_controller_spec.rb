require "rails_helper"

RSpec.describe HealthcheckController, type: :controller do
  describe "GET #perform" do
    it "regenerate_keys the keys of the requested project" do
      get :perform
      expect(response.status).to eq 200
    end
  end
end
