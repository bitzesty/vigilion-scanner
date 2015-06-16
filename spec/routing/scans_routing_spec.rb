require "rails_helper"

RSpec.describe ScansController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/scans").to route_to("scans#index")
    end

    it "routes to #new" do
      expect(:get => "/scans/new").to route_to("scans#new")
    end

    it "routes to #show" do
      expect(:get => "/scans/1").to route_to("scans#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/scans/1/edit").to route_to("scans#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/scans").to route_to("scans#create")
    end

    it "routes to #update" do
      expect(:put => "/scans/1").to route_to("scans#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/scans/1").to route_to("scans#destroy", :id => "1")
    end

  end
end
