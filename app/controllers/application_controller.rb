class ApplicationController < ActionController::API
  before_action :authenticate_user!

  private

  def authorize_user!
    is_authorized = request.fullpath.split('/')[1] == 'admin' && current_user&.is_admin?

    render json: { message: "You're not authorized" }, :status => :unauthorized unless is_authorized
  end
end
