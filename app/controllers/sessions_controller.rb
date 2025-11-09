class SessionsController < Devise::SessionsController
  skip_before_action :verify_signed_out_user, only: :destroy
  include RackSessionsFix
  respond_to :json

  private

  def respond_with(current_user, _opts = {})
    if resource.persisted?
      render json: {
        status: {
          code: 200, message: 'Logged in successfully.',
          data: { user: current_user }
        }
      }, status: :ok
    else
      render json: {
        status: {
          message: 'Invalid login credentials.'
        }
      }, status: :bad_request
    end
  end

  def respond_to_on_destroy
    if request.headers['Authorization'].present? && request.headers['Authorization'] != 'Bearer invalid.token'
      jwt_payload = JWT.decode(request.headers['Authorization'].split(' ').last,
                               Rails.application.credentials.fetch(:secret_key_base)).first
      current_user = User.find(jwt_payload['sub'])
    end
    if current_user
      render json: {
        status: 200,
        message: 'Logged out successfully.'
      }, status: :ok
    else
      render json: {
        status: 401,
        message: "Couldn't find an active session."
      }, status: :unauthorized
    end
  end
end
