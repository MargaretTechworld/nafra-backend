class ApplicationController < ActionController::API
  # Method to retrieve the current user from the JWT token in the Authorization header.
  def current_user
    return nil unless request.headers['Authorization']

    token = request.headers['Authorization'].split(' ').last
    decoded = decode_jwt_token(token)
    return nil unless decoded

    @current_user ||= User.find_by(id: decoded[:user_id])
  rescue JWT::DecodeError
    nil
  end

  # Standardized JWT encoding
  def generate_jwt_token(user_id, expires_in: 24.hours)
    exp = Time.current.to_i + expires_in.to_i
    payload = {
      user_id: user_id,
      exp: exp,
      iat: Time.current.to_i,
      iss: 'nafra-api',
      aud: 'nafra-frontend'
    }
    JWT.encode(payload, Rails.application.secret_key_base, 'HS256')
  end

  # Standardized JWT decoding
  def decode_jwt_token(token)
    decoded = JWT.decode(
      token,
      Rails.application.secret_key_base,
      true,
      { algorithm: 'HS256', iss: 'nafra-api', aud: 'nafra-frontend' }
    )[0]
    HashWithIndifferentAccess.new(decoded)
  rescue JWT::ExpiredSignature, JWT::VerificationError, JWT::DecodeError
    nil
  end

  # Method to authenticate the user; returns 401 if not authenticated.
  def authenticate_user!
    render json: { error: 'Unauthorized' }, status: :unauthorized unless current_user
  end
end