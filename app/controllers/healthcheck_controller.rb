class HealthcheckController < ActionController::Base
  def perform
    head :no_content
  end
end
