require_relative 'authorizations/base_authorization'
require_relative 'authorizations/client_authorization'
require_relative 'authorizations/dashboard_authorization'

class ApplicationController < ActionController::API
  before_action :change_default_response
  before_action :authenticate!

  def change_default_response
    request.format = 'json'
  end

  def authenticate!
    authorization_policy.authenticate!
  end

  def authorize_admin!
    authorization_policy.authorize_admin!
  end

  def current_project
    authorization_policy.current_project
  end

  def current_account
    current_project.account
  end

  private

  def authorization_policy
    @authorization_policy ||= if request.headers['Dashboard-Auth-Key']
                                DashboardAuthorization.new(self)
                              else
                                ClientAuthorization.new(self)
                              end
  end
end
