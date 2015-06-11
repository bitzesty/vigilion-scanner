class ApplicationController < ActionController::Base
  before_action :change_default_response
  before_action :authenticate!

  def change_default_response
    request.format = "json"
  end

  def authenticate!
    error!("Unauthorized. Invalid token", 401) unless authenticated?
  end

  def error!(message, status)
    render json: { message: message }, status: status
  end

  def authenticated?
    current_account.present?
  end

  def current_account
    Account.find_by_access_key_id(authorization_token)
  end

  def authorization_token
    request.headers["X-Auth-Token"]
  end
end
