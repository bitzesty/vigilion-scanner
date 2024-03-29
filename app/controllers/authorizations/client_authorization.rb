class Authorizations::ClientAuthorization < Authorizations::BaseAuthorization
  def current_project
    @current_project ||= Project.find_by_access_key_id(authorization_token)
  end

  def authorize_admin!
    controller.head :forbidden
  end

  def authenticated?
    current_project.present?
  end

  private

  def authorization_token
    request.headers['X-Api-Key']
  end
end
