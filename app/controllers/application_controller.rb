class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

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
