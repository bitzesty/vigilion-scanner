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
    current_project.present? && valid_hash?
  end

  def valid_hash?
    authorization_hash == digest(request.raw_post, current_project.secret_access_key)
  end

  def current_project
    @current_project ||= Project.find_by_access_key_id(authorization_token)
  end

  def authorization_token
    request.headers["Auth-Key"]
  end

  def authorization_hash
    request.headers["Auth-Hash"]
  end

  def digest(body, secret_access_key)
    Digest::MD5.hexdigest("#{body}#{secret_access_key}")
  end
end
