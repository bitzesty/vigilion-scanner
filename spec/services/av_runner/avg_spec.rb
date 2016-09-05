require "open3"
require "rails_helper"

RSpec.describe AvRunner::Avg do
  describe "#perform!" do
    before do
      mock_avscan
    end

    after do
      scan.delete_file
    end

    let(:project) {
      plan = create :plan, clamav: false, avg: true
      account = create :account, plan: plan
      create :project, account: account
    }
    let(:scan) {
      create :scan,
             project: project,
             file: OpenStruct.new(read: "something")
    }
    let(:avscan_response) { OpenStruct.new }

    let(:result) { AvRunner::Avg.new(scan).perform! }

    context "with exitstatus=0" do
      it "marks scan as clean" do
        expect(result).to eq(status: :clean, message: "Stubbed Result")
      end
    end

    context "with exitstatus=1" do
      before { avscan_response.value.exitstatus = 1 }

      it "marks scan as error" do
        expect(result[:status]).to eq(:error)
      end
    end

    context "with exitstatus=2" do
      before { avscan_response.value.exitstatus = 2 }

      it "marks scan as error" do
        expect(result[:status]).to eq(:error)
      end
    end

    context "with exitstatus=3" do
      before { avscan_response.value.exitstatus = 3 }

      it "marks scan as error" do
        expect(result[:status]).to eq(:error)
      end
    end

    context "with exitstatus=4" do
      before { avscan_response.value.exitstatus = 4 }

      it "marks scan as pua" do
        expect(result[:status]).to eq(:infected)
      end
    end

    context "with exitstatus=5" do
      before { avscan_response.value.exitstatus = 5 }

      it "marks scan as infected" do
        expect(result[:status]).to eq(:infected)
      end
    end

    context "with exitstatus=6" do
      before { avscan_response.value.exitstatus = 6 }

      it "marks scan as password protected" do
        expect(result[:status]).to eq(:password_protected)
      end
    end

    context "performing a new scan over the same file" do
      before do
        AvRunner.new.perform(scan)
      end

      after do
        Scan.destroy_all
      end

      it "avoids scanning twice" do
        expect(Open3).not_to receive(:popen3)
        new_scan = create(:scan, file: scan.file, project: scan.project)
        AvRunner.new.perform(new_scan)
        expect(scan).to be_clean
      end

      context "with forced scan" do
        it "performs the scan again" do
          mock_avscan
          new_scan = create(:scan, file: scan.file, force: true, project: scan.project)
          AvRunner.new.perform(new_scan)
          expect(scan).to be_clean
        end
      end
    end

    def mock_avscan
      avscan_response.value = OpenStruct.new
      avscan_response.value.exitstatus = 0
      stdout = OpenStruct.new
      stdout.read = "\n\n\n\n\n\nStubbed Result"
      expect(Open3).to receive(:popen3).and_yield(nil, stdout, nil, avscan_response)
    end
  end
end
