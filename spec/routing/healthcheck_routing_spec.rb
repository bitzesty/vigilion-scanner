require "rails_helper"

RSpec.describe HealthcheckController, type: :routing do
  describe "routing" do
    it "routes to #healthcheck" do
      expect(:get => "/healthcheck").to route_to("healthcheck#perform")
    end
  end
end
