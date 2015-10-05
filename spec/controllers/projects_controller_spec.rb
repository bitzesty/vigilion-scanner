require "rails_helper"

RSpec.describe ProjectsController, type: :controller do
  let(:valid_attributes) { attributes_for :project }
  let(:invalid_attributes) { attributes_for :project, name: nil }

  context "as dashboard" do
    before do
      request.headers["Dashboard-Auth-Key"] = "vigilion"
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
