require "rails_helper"

RSpec.describe ProjectsController, type: :controller do
  let(:valid_attributes) { attributes_for :project }
  let(:invalid_attributes) { attributes_for :project, name: nil }

  context "using the dashboard" do
    before do
      request.headers["Dashboard-Auth-Key"] = CONFIG["dashboard_api_key"]
    end

    describe "GET #index" do
      it "load projects filtered by account" do
        account = create :account
        account_project = create :project, account: account
        another_project = create :project

        get :index, { account_id: account.id }
        expect(assigns(:projects)).to eq([account_project])
      end

      describe "view" do
        render_views

        it "includes an array with projects" do
          project = create :project
          get :index, { account_id: project.account_id }
          json = JSON.parse(response.body)
          expect(json.count).to eq 1
          expect(json.first["id"]).to eq project.id
          expect(json.first["name"]).to eq project.name
          expect(json.first["callback_url"]).to eq project.callback_url
          expect(json.first["account_id"]).to eq project.account_id
        end
      end
    end

    describe "POST #regenerate_keys" do
      it "regenerate_keys the keys of the requested project" do
        project = create(:project)
        old_access_key_id = project.access_key_id
        old_secret_access_key = project.secret_access_key
        post :regenerate_keys, { id: project.to_param }
        project.reload
        expect(project.access_key_id).not_to eq(old_access_key_id)
        expect(project.secret_access_key).not_to eq(old_secret_access_key)
      end

      it "assigns the requested project as @project" do
        project = create(:project)
        post :regenerate_keys, { id: project.to_param }
        expect(assigns(:project)).to eq(project)
      end
    end
  end

  context "as a client" do
    let!(:current_project) { create :project }

    before do
      request.headers["Auth-Key"] = current_project.access_key_id
    end

    describe "GET #validate" do
      it "assigns the requested project as @project" do
        get :validate
        expect(assigns(:project)).to eq(current_project)
      end
    end
  end
end
