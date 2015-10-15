require 'rails_helper'

RSpec.describe AccountsController, type: :controller do

  let(:plan) { create :plan }
  let(:valid_attributes) { attributes_for :account, plan_id: plan.id }
  let(:invalid_attributes) { attributes_for :account, plan_id: nil }

  context "using the dashboard" do
    before do
      request.headers["Dashboard-Auth-Key"] = CONFIG["dashboard_api_key"]
    end

    describe "GET #show" do
      it "assigns the requested account as @account" do
        account = Account.create! valid_attributes
        get :show, {:id => account.to_param}
        expect(assigns(:account)).to eq(account)
      end
    end

    describe "POST #create" do
      context "with valid params" do
        it "creates a new Account" do
          expect {
            post :create, {:account => valid_attributes}
          }.to change(Account, :count).by(1)
        end

        it "assigns a newly created account as @account" do
          post :create, {:account => valid_attributes}
          expect(assigns(:account)).to be_a(Account)
          expect(assigns(:account).plan).to eq(plan)
          expect(assigns(:account)).to be_enabled
          expect(assigns(:account)).to be_persisted
        end

        it "shows the created account" do
          post :create, {:account => valid_attributes}
          expect(response).to be_created
        end
      end

      context "with invalid params" do
        it "assigns a newly created but unsaved account as @account" do
          post :create, {:account => invalid_attributes}
          expect(assigns(:account)).to be_a_new(Account)
          expect(assigns(:account)).not_to be_persisted
        end

        it "returns unprocessable_entity" do
          post :create, {:account => invalid_attributes}
          expect(response.status).to eq(422)
        end
      end
    end

    describe "PUT #update" do
      context "with valid params" do
        let(:new_attributes) { { enabled: false } }

        it "updates the requested account" do
          account = Account.create! valid_attributes
          put :update, {:id => account.to_param, :account => new_attributes}
          account.reload
          expect(account).not_to be_enabled
        end

        it "assigns the requested account as @account" do
          account = Account.create! valid_attributes
          put :update, {:id => account.to_param, :account => valid_attributes}
          expect(assigns(:account)).to eq(account)
        end

        it "shows the updated account" do
          account = Account.create! valid_attributes
          put :update, {:id => account.to_param, :account => valid_attributes}
          expect(response).to be_ok
        end
      end

      context "with invalid params" do
        it "assigns the account as @account" do
          account = Account.create! valid_attributes
          put :update, {:id => account.to_param, :account => invalid_attributes}
          expect(assigns(:account)).to eq(account)
        end

        it "returns unprocessable_entity" do
          account = Account.create! valid_attributes
          put :update, {:id => account.to_param, :account => invalid_attributes}
          expect(response.status).to eq(422)
        end
      end
    end

    describe "DELETE #destroy" do
      it "destroys the requested account" do
        account = Account.create! valid_attributes
        expect {
          delete :destroy, {:id => account.to_param}
        }.to change(Account, :count).by(-1)
      end

      it "returns no content" do
        account = Account.create! valid_attributes
        delete :destroy, {:id => account.to_param}
        expect(response.status).to be(204)
      end
    end
  end
end
