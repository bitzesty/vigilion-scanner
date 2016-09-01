require "rails_helper"
require "open3"

RSpec.describe AvRunner::Clamav do
  describe "#perform!" do
    before do
      mock_clamavscan
    end

    after do
      scan.delete_file
    end

    let(:scan) { create :scan, file: OpenStruct.new(read: "something") }
    let(:avscan_response) { OpenStruct.new }
    let(:result) { AvRunner::Clamav.new(scan).perform! }

    context "with exitstatus=0" do
      it "returns clean result" do
        expect(result).to eq(status: :clean, message: "Stubbed Result")
      end
    end

    context "with exitstatus=1" do
      before { avscan_response.value.exitstatus = 1 }

      it "marks scan as infected" do
        expect(result).to eq(status: :infected, message: "Stubbed Result")
      end
    end

    context "with exitstatus=2" do
      before { avscan_response.value.exitstatus = 2 }

      it "marks scan as error" do
        expect(result).to eq(status: :error, message: "Stubbed Result")
     end
    end

    def mock_clamavscan
      avscan_response.value = OpenStruct.new
      avscan_response.value.exitstatus = 0
      stdout = OpenStruct.new
      stdout.read = "Stubbed Result"
      expect(Open3).to receive(:popen3).and_yield(nil, stdout, nil, avscan_response)
    end
  end
end
