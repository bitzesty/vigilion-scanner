require 'rails_helper'

RSpec.describe ScanWorker do
  describe "#perform" do
    it "executes ScanService" do
      scan = create :scan
      ScanService.any_instance.should_receive(:perform).with(scan)
      ScanWorker.new.perform(nil, "id" => scan.id)
    end
  end
end