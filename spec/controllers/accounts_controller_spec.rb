require 'rails_helper'

RSpec.describe AccountsController, type: :controller do

  let(:valid_attributes) {
    attributes_for :account
  }

  let(:invalid_attributes) {
    attributes_for :account, name: nil
  }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # AccountsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET #index" do
    it "assigns all accounts as @accounts" do
      account = create(:account)
      get :index, {}, valid_session
      expect(assigns(:accounts)).to eq([account])
    end
  end

  describe "GET #show" do
    it "assigns the requested account as @account" do
      account = create(:account)
      get :show, {:id => account.to_param}, valid_session
      expect(assigns(:account)).to eq(account)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Account" do
        expect {
          post :create, {:account => valid_attributes}, valid_session
        }.to change(Account, :count).by(1)
      end

      it "assigns a newly created account as @account" do
        post :create, {:account => valid_attributes}, valid_session
        expect(assigns(:account)).to be_a(Account)
        expect(assigns(:account)).to be_persisted
      end

      it "returns 201 (created)" do
        post :create, {:account => valid_attributes}, valid_session
        expect(response).to be_created
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved account as @account" do
        post :create, {:account => invalid_attributes}, valid_session
        expect(assigns(:account)).to be_a_new(Account)
      end

      it "returns 422 (unprocessable entity)" do
        post :create, {:account => invalid_attributes}, valid_session
        expect(response.status).to eq(422)
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      it "updates the requested account" do
        account = create(:account)
        new_attributes = valid_attributes
        put :update, {:id => account.to_param, :account => new_attributes}, valid_session
        account.reload
        expect(account.name).to eq new_attributes[:name]
      end

      it "assigns the requested account as @account" do
        account = create(:account)
        put :update, {:id => account.to_param, :account => valid_attributes}, valid_session
        expect(assigns(:account)).to eq(account)
      end

      it "returns 200 (OK)" do
        account = create(:account)
        put :update, {:id => account.to_param, :account => valid_attributes}, valid_session
        expect(response).to be_ok
      end
    end

    context "with invalid params" do
      it "assigns the account as @account" do
        account = create(:account)
        put :update, {:id => account.to_param, :account => invalid_attributes}, valid_session
        expect(assigns(:account)).to eq(account)
      end

      it "returns 422 (unprocessable entity)" do
        account = create(:account)
        put :update, {:id => account.to_param, :account => invalid_attributes}, valid_session
        expect(response.status).to eq(422)
      end
    end
  end

  describe "POST #regenerate_keys" do
    it "regenerate_keys the keys of the requested account" do
      account = create(:account)
      old_access_key_id = account.access_key_id
      old_secret_access_key = account.secret_access_key
      post :regenerate_keys, {:id => account.to_param }, valid_session
      account.reload
      expect(account.access_key_id).not_to eq(old_access_key_id)
      expect(account.secret_access_key).not_to eq(old_secret_access_key)
    end

    it "assigns the requested account as @account" do
      account = create(:account)
      post :regenerate_keys, {:id => account.to_param }, valid_session
      expect(assigns(:account)).to eq(account)
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested account" do
      account = create(:account)
      expect {
        delete :destroy, {:id => account.to_param}, valid_session
      }.to change(Account, :count).by(-1)
    end

    it "returns 204 (no content)" do
      account = create(:account)
      delete :destroy, {:id => account.to_param}, valid_session
      expect(response.status).to eq(204)
    end
  end

end
