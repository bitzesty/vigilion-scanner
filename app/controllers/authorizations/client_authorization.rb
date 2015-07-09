class ClientAuthorization < BaseAuthorization
  def current_project
    @current_project ||= Project.find_by_access_key_id(authorization_token)
  end

  def authorize_admin!
    controller.head :forbidden
  end

  def authenticated?
    current_project.present? && valid_hash?
  end

private

  def valid_hash?
    authorization_hash == digest(request.raw_post, current_project.secret_access_key)
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
