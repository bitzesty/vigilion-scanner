require 'rails_helper'

RSpec.describe ScansController, type: :controller do

  let(:valid_attributes) {
    attributes_for :scan
  }

  let(:invalid_attributes) {
    attributes_for :scan, key: nil
  }

  let(:current_account) {
    create :account
  }

  before do
    request.headers["Auth-Key"] = current_account.access_key_id
  end

  describe "GET #index" do
    it "assigns current_account scans as @scans" do
      scan = create :scan, account: current_account
      get :index, {}
      expect(assigns(:scans)).to eq([scan])
    end

    it "excludes scans of another account" do
      scan = create :scan
      get :index, {}
      expect(assigns(:scans)).not_to include(scan)
    end
  end

  describe "GET #stats" do
    it "assigns current_account scans as @scans" do
      scan = create(:scan, created_at: 1.hour.ago, account: current_account)
      get :stats
      expect(assigns(:scans)).to include(scan.created_at.beginning_of_minute => 1)
    end

    context "with infected status" do
      it "assigns current_account infected scans as @scans" do
        scan = create(:scan, account: current_account, status: "infected", created_at: 1.hour.ago)
        get :stats, { status: "infected" }
        expect(assigns(:scans)).to include(scan.created_at.beginning_of_minute => 1)
      end

      it "does not include current_account clean scans as @scans" do
        scan = create(:scan, account: current_account, status: "clean", created_at: 1.hour.ago)
        get :stats, { status: "infected" }
        expect(assigns(:scans)).to include(scan.created_at.beginning_of_minute => 0)
      end
    end
  end

  describe "GET #show" do
    context "for current_account" do
      it "assigns the requested scan as @scan" do
        scan = create :scan, account: current_account
        get :show, {:id => scan.to_param}
        expect(assigns(:scan)).to eq(scan)
      end
    end

    context "for another account" do
      it "raises RecordNotFound" do
        scan = create :scan
        expect{ get :show, {:id => scan.to_param} }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "POST #create" do
    context "with valid params" do
      before do
        expect(ScanWorker).to receive(:perform_async)
      end

      it "creates a new Scan" do
        expect {
          post :create, {:scan => valid_attributes}
        }.to change(Scan, :count).by(1)
      end

      it "assigns a newly created scan as @scan" do
        post :create, {:scan => valid_attributes}
        expect(assigns(:scan)).to be_a(Scan)
        expect(assigns(:scan)).to be_persisted
      end

      it "returns 201 (created)" do
        post :create, {:scan => valid_attributes}
        expect(response).to be_created
      end

      describe "view" do
        render_views

        it "includes id and status" do
          post :create, {:scan => valid_attributes}
          expect(response.body).to match Scan.last.id
          expect(response.body).to match Scan.last.status
        end
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved scan as @scan" do
        post :create, {:scan => invalid_attributes}
        expect(assigns(:scan)).to be_a_new(Scan)
      end

      it "returns 422 (unprocessable entity)" do
        post :create, {:scan => invalid_attributes}
        expect(response.status).to eq(422)
      end
    end

    context "without valid credentials" do
      it "returns 401 (Unauthorized)" do
        request.headers["Auth-Key"] = nil
        post :create, {:scan => valid_attributes}
        expect(response.status).to eq(401)
      end
    end
  end
end
