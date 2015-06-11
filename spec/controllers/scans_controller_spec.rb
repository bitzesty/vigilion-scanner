require 'rails_helper'

RSpec.describe ScansController, type: :controller do

  let(:valid_attributes) {
    attributes_for :scan
  }

  let(:invalid_attributes) {
    attributes_for :scan, url: nil
  }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # ScansController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET #index" do
    it "assigns all scans as @scans" do
      scan = Scan.create! valid_attributes
      get :index, {}, valid_session
      expect(assigns(:scans)).to eq([scan])
    end
  end

  describe "GET #show" do
    it "assigns the requested scan as @scan" do
      scan = Scan.create! valid_attributes
      get :show, {:id => scan.to_param}, valid_session
      expect(assigns(:scan)).to eq(scan)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Scan" do
        expect {
          post :create, {:scan => valid_attributes}, valid_session
        }.to change(Scan, :count).by(1)
      end

      it "assigns a newly created scan as @scan" do
        post :create, {:scan => valid_attributes}, valid_session
        expect(assigns(:scan)).to be_a(Scan)
        expect(assigns(:scan)).to be_persisted
      end

      it "returns 201 (created)" do
        post :create, {:scan => valid_attributes}, valid_session
        expect(response).to be_created
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved scan as @scan" do
        post :create, {:scan => invalid_attributes}, valid_session
        expect(assigns(:scan)).to be_a_new(Scan)
      end

      it "returns 422 (unprocessable entity)" do
        post :create, {:scan => invalid_attributes}, valid_session
        expect(response.status).to eq(422)
      end
    end
  end
end
