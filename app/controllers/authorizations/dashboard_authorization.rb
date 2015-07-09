class DashboardAuthorization < BaseAuthorization
  def current_project
    @current_project ||= Project.find(params[:project_id])
  end

  def authorize_admin!
    # sure!
  end

  def authenticated?
    authorization_token == CONFIG[:dashboard_api_key]
  end

private

  def authorization_token
    request.headers["Dashboard-Auth-Key"]
  end
end
