require 'rails_helper'

RSpec.describe ScanWorker do
  describe "#perform" do
    it "executes ScanService" do
      scan = create :scan
      expect_any_instance_of(ScanService).to receive(:perform).with(scan)
      ScanWorker.new.perform(nil, "id" => scan.id)
    end
  end
end
