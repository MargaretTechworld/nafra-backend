class ApplicationController < ActionController::API
  # Method to retrieve the current user from the JWT token in the Authorization header.
  def current_user
    return nil unless request.headers['Authorization']

    token = request.headers['Authorization'].split(' ').last
    decoded = JWT.decode(token, Rails.application.secret_key_base)[0]
    @current_user ||= User.find(decoded['user_id'])
  rescue JWT::DecodeError
    nil
  end

  # Method to authenticate the user; returns 401 if not authenticated.
  def authenticate_user!
    render json: { error: 'Unauthorized' }, status: :unauthorized unless current_user
  end
end