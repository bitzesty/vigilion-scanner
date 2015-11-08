class PlansController < ApplicationController
  # GET /plans
  # GET /plans.json
  def index
    @plans = Plan.available_for_new_subscriptions
  end

  def plan
    @plan = Plan.find(params[:id])
  end
end
