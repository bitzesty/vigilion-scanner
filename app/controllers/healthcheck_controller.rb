class HealthcheckController < ActionController::Base
  def perform
    render plain: "OK"
  end
end
