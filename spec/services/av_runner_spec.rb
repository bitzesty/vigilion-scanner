require "rails_helper"
require "open3"

RSpec.describe AvRunner do
  describe "#perform" do
    before do
      mock_avscan
    end

    after do
      scan.delete_file
    end

    let(:scan) { create :scan, file: OpenStruct.new(read: "something") }
    let(:avscan_response) { OpenStruct.new }

    context "with exitstatus=0" do
      it "marks scan as clean" do
        AvRunner.new.perform(scan)
        expect(scan).to be_clean
        expect(scan.result).to eq("Stubbed Result")
      end
    end

    context "with exitstatus=1" do
      before { avscan_response.value.exitstatus = 1 }

      it "marks scan as infected" do
        AvRunner.new.perform(scan)
        expect(scan).to be_infected
      end
    end

    context "with exitstatus=2" do
      before { avscan_response.value.exitstatus = 2 }

      it "marks scan as error" do
        AvRunner.new.perform(scan)
        expect(scan).to be_error
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
        AvRunner.new.perform(create(:scan, file: scan.file))
        expect(scan).to be_clean
      end

      context "with forced scan" do
        it "performs the scan again" do
          mock_avscan
          AvRunner.new.perform(create(:scan, file: scan.file, force: true))
          expect(scan).to be_clean
        end
      end
    end

    def mock_avscan
      avscan_response.value = OpenStruct.new
      avscan_response.value.exitstatus = 0
      stdout = OpenStruct.new
      stdout.read = "Stubbed Result"
      expect(Open3).to receive(:popen3).and_yield(nil, stdout, nil, avscan_response)
    end
  end
end
