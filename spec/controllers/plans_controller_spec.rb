require 'rails_helper'

RSpec.describe PlansController, type: :controller do
  before do
    request.headers["Dashboard-Auth-Key"] = CONFIG["dashboard_api_key"]
  end

  describe "GET #index" do
    it "assigns all plans as @plans" do
      plan = create :plan
      get :index
      expect(assigns(:plans)).to eq([plan])
    end

    it "hides plans not available for new subscriptions" do
      plan = create :plan, available_for_new_subscriptions: false
      get :index
      expect(assigns(:plans)).to eq([])
    end

    describe "view" do
      render_views

      it "includes an array with plans" do
        plan = create :plan
        get :index
        json = JSON.parse(response.body)
        expect(json.count).to eq 1
        expect(json.first["id"]).to eq plan.id
        expect(json.first["name"]).to eq plan.name
        expect(json.first["cost"]).to eq plan.cost.to_s
        expect(json.first["file_size_limit"]).to eq plan.file_size_limit.to_s
        expect(json.first["scans_per_month"]).to eq plan.scans_per_month
      end
    end
  end
end
