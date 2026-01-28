class Api::AuthController < ApplicationController

  private

  def generate_jwt_token(user_id, expires_in: 30.minutes)
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

  def decode_jwt_token(token)
    JWT.decode(
      token, 
      Rails.application.secret_key_base, 
      true, 
      { algorithm: 'HS256', iss: 'nafra-api', aud: 'nafra-frontend' }
    )[0]
  rescue JWT::ExpiredSignature, JWT::VerificationError => e
    nil
  end

  public

  def login
    user = User.find_by(email: params[:email])

    if user&.authenticate(params[:password])
      token = generate_jwt_token(user.id)
      render json: { token: token, role: user.role, user_id: user.id }, status: :ok
    else
      render json: { error: 'Invalid email or password' }, status: :unauthorized
    end
  rescue StandardError => e
    render json: { error: 'Authentication failed', details: e.message }, status: :internal_server_error
  end

  def register
    # Only admins can create new users via API
    admin_token = request.headers['Authorization']&.split(' ')&.last

    if admin_token
      decoded = decode_jwt_token(admin_token)
      admin = User.find(decoded['user_id']) if decoded
    end

    unless admin&.admin?
      return render json: { error: 'Only admins can register new users' }, status: :forbidden
    end

    user = User.new(
      name: params[:name],
      email: params[:email],
      password: params[:password],
      password_confirmation: params[:password_confirmation],
      role: params[:role] || 'agency'
    )

    if user.save
      render json: {
        user_id: user.id,
        name: user.name,
        email: user.email,
        role: user.role,
        message: 'User created successfully'
      }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  rescue StandardError => e
    render json: { error: 'Registration failed', details: e.message }, status: :internal_server_error
  end

  def admin_setup
    # Only allow if no users exist (first time setup)
    if User.exists?
      return render json: { error: 'System already initialized. Admin user already exists.' }, status: :forbidden
    end

    user = User.new(
      name: params[:name],
      email: params[:email],
      password: params[:password],
      password_confirmation: params[:password_confirmation],
      role: 'admin'
    )

    if user.save
      token = generate_jwt_token(user.id)
      render json: {
        message: 'Admin user created successfully',
        user_id: user.id,
        name: user.name,
        email: user.email,
        role: user.role,
        token: token
      }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  rescue StandardError => e
    render json: { error: 'Admin setup failed', details: e.message }, status: :internal_server_error
  end

  def agency_setup
    admin_token = request.headers['Authorization']&.split(' ')&.last

    unless admin_token
      return render json: { error: 'Missing or invalid authorization token' }, status: :unauthorized
    end

    decoded = decode_jwt_token(admin_token)
    unless decoded
      return render json: { error: 'Invalid or expired token' }, status: :unauthorized
    end

    admin = User.find(decoded['user_id'])
    unless admin&.admin?
      return render json: { error: 'Only admins can create agencies' }, status: :forbidden
    end

    name = params[:name]
    agency_name = params[:agency_name]
    project_name = params[:project_name]
    ministry = params[:ministry]
    email = params[:email]
    password = params[:password]
    password_confirmation = params[:password_confirmation]

    # Validate required fields
    if agency_name.blank? || project_name.blank? || ministry.blank? || email.blank? || password.blank?
      return render json: { error: 'agency_name, project_name, ministry, email, password, and password_confirmation are required' }, status: :unprocessable_entity
    end

    # Create user and agency in transaction
    ActiveRecord::Base.transaction do
      user = User.new(
        name: name,
        email: email,
        password: password,
        password_confirmation: password_confirmation,
        role: 'agency'
      )

      unless user.save
        raise ActiveRecord::Rollback, user.errors.full_messages.join(', ')
      end

      agency = Agency.new(
        name: agency_name,
        project_name: project_name,
        ministry: ministry,
        user_id: user.id
      )

      unless agency.save
        raise ActiveRecord::Rollback, agency.errors.full_messages.join(', ')
      end

      render json: {
        message: 'Agency and user created successfully',
        user: {
          user_id: user.id,
          name: user.name,
          email: user.email,
          role: user.role
        },
        agency: {
          agency_id: agency.id,
          name: agency.name,
          project_name: agency.project_name,
          ministry: agency.ministry,
          user_id: user.id
        }
      }, status: :created
    end
  rescue => e
    render json: { error: 'Agency setup failed', details: e.message }, status: :internal_server_error
  end
end
