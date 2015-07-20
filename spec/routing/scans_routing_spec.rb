require "rails_helper"

RSpec.describe ScansController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(:get => "/scans").to route_to("scans#index")
    end

    it "routes to #show" do
      expect(:get => "/scans/1").to route_to("scans#show", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/scans").to route_to("scans#create")
    end

    it "routes to #stats" do
      expect(:get => "/scans/stats").to route_to("scans#stats")
    end
  end
end
