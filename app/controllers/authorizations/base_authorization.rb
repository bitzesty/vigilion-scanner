class Authorizations::BaseAuthorization
  def initialize(controller)
    @controller = controller
  end

  def authenticate!
    @controller.head :unauthorized unless authenticated?
  end

private

  def request
    @controller.request
  end

  def params
    @controller.params
  end
end
