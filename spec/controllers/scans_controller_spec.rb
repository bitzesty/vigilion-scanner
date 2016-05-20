require "rails_helper"

RSpec.describe ScansController, type: :controller do
  let(:valid_attributes) { attributes_for :scan }
  let(:invalid_attributes) { attributes_for :scan, key: nil }
  let!(:current_project) { create :project }

  before do
    request.headers["X-Api-Key"] = current_project.access_key_id
  end

  describe "GET #index" do
    it "assigns current_project scans as @scans" do
      scan = create :scan, project: current_project
      get :index, params: {}
      expect(assigns(:scans)).to eq([scan])
    end

    it "excludes scans of another project" do
      scan = create :scan
      get :index, params: {}
      expect(assigns(:scans)).not_to include(scan)
    end

    it "excludes old scans" do
      scan = create :scan, project: current_project, created_at: 1.day.ago
      get :index, params: {}
      expect(assigns(:scans)).not_to include(scan)
    end

    context "with infected status" do
      it "excludes clean" do
        scan = create :scan, project: current_project, status: :clean
        get :index, params: { status: "infected" }
        expect(assigns(:scans)).not_to include(scan)
      end
    end

    context "with some url" do
      it "includes similar url" do
        scan = create :scan, project: current_project, url: "http://some/123"
        get :index, params: { url: "some" }
        expect(assigns(:scans)).to include(scan)
      end

      it "excludes other url" do
        scan = create :scan, project: current_project, url: "http://other"
        get :index, params: { url: "some" }
        expect(assigns(:scans)).not_to include(scan)
      end
    end
  end

  describe "GET #stats" do
    it "groups @scans by day and fills with zeroes" do
      scans = create_list(:scan, 3, project: current_project)
      get :stats
      expect(assigns(:scans)).to include(scans.first.created_at.utc.beginning_of_day => 3)
      expect(assigns(:scans)).to include(scans.first.created_at.utc.beginning_of_day - 1.day => 0)
    end

    it "excludes scans older than 90 days" do
      scan = create :scan, project: current_project, created_at: 90.days.ago
      get :index, params: {}
      expect(assigns(:scans)).not_to include(scan.created_at.utc.beginning_of_day => 0)
    end

    context "with infected status" do
      it "assigns current_project infected scans as @scans" do
        scan = create(:scan, project: current_project, status: "infected", created_at: 1.hour.ago)
        get :stats, params: { status: "infected" }
        expect(assigns(:scans)).to include(scan.created_at.utc.beginning_of_day => 1)
      end

      it "does not include current_project clean scans as @scans" do
        scan = create(:scan, project: current_project, status: "clean", created_at: 1.hour.ago)
        get :stats, params: { status: "infected" }
        expect(assigns(:scans)).to include(scan.created_at.utc.beginning_of_day => 0)
      end
    end
  end

  describe "GET #show" do
    context "for current_project" do
      it "assigns the requested scan as @scan" do
        scan = create :scan, project: current_project
        get :show, params: { id: scan.to_param }
        expect(assigns(:scan)).to eq(scan)
      end
    end

    context "for another account" do
      it "raises RecordNotFound" do
        scan = create :scan
        expect { get :show, params: { id: scan.to_param } }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "POST #create" do
    context "with valid params" do
      context "with a scan allowed to the account" do
        before do
          expect(ScanWorker).to receive(:perform_async)
        end

        it "creates a new Scan" do
          expect {
            post :create, params: { scan: valid_attributes }
          }.to change(Scan, :count).by(1)
        end

        it "assigns a newly created scan as @scan" do
          post :create, params: { scan: valid_attributes }
          expect(assigns(:scan)).to be_a(Scan)
          expect(assigns(:scan)).to be_persisted
        end

        it "returns 201 (created)" do
          post :create, params: { scan: valid_attributes }
          expect(response).to be_created
        end
      end

      context "with a scan not allowed to the account" do
        before do
          expect_any_instance_of(Account).to receive(:allow_more_scans?).and_return(false)
        end

        it "doesn't create a scan" do
          expect { post :create, params: { scan: valid_attributes }
            }.not_to change{ Scan.count }
        end

        it "returns 402 (payment required)" do
          post :create, params: { scan: valid_attributes }
          expect(response.status).to eq(402)
        end

        it "should return a JSON" do
          post :create, params: { scan: valid_attributes }
          expect(JSON.parse(response.body)).to eq("error" => "The current account reached its monthly scan limit")
        end
      end

      context "with an attached file of 8 bytes" do
        let(:file) { fixture_file_upload("file.txt", "text/xml") }
        let(:attributes_with_file){ valid_attributes.merge(file: file) }

        context "with a file size limit of 0MB" do
          before do
            current_project.account.plan.update(file_size_limit: 0)
          end

          it "doesn't create a scan" do
            expect { post :create, params: { scan: attributes_with_file }
              }.not_to change{ Scan.count }
          end

          it "returns 402 (payment required)" do
            post :create, params: {scan: attributes_with_file }
            expect(response.status).to eq(402)
          end

          it "should return a JSON" do
            post :create, params: { scan: attributes_with_file }
            expect(JSON.parse(response.body)).to eq("error" => "File too large for this plan")
          end
        end

        context "with a file size limit of 1MB" do
          before do
            current_project.account.plan.update(file_size_limit: 1)
          end

          it "returns 201 (created)" do
            post :create, params: { scan: attributes_with_file }
            expect(response).to be_created
          end
        end
      end

      describe "view" do
        render_views

        it "includes id and status" do
          post :create, params: { scan: valid_attributes }
          expect(response.body).to match Scan.last.id
          expect(response).to have_http_status(:created)
        end
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved scan as @scan" do
        post :create, params: { scan: invalid_attributes }
        expect(assigns(:scan)).to be_a_new(Scan)
      end

      it "returns 422 (unprocessable entity)" do
        post :create, params: { scan: invalid_attributes }
        expect(response.status).to eq(422)
      end
    end

    context "without valid credentials" do
      it "returns 401 (Unauthorized)" do
        request.headers["X-Api-Key"] = nil
        post :create, params: { scan: valid_attributes }
        expect(response.status).to eq(401)
      end
    end
  end
end
