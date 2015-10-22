require "rails_helper"

RSpec.describe PlansController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(:get => "/plans").to route_to("plans#index")
    end
  end
end
