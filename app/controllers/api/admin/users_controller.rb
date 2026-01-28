class Api::Admin::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin

  def index
    users = User.all
    render json: users.map { |u| serialize_user(u) }, status: :ok
  rescue StandardError => e
    render json: { error: 'Failed to fetch users', details: e.message }, status: :internal_server_error
  end

  def show
    user = User.find_by(id: params[:id])
    unless user
      return render json: { error: 'User not found' }, status: :not_found
    end

    render json: serialize_user(user), status: :ok
  rescue StandardError => e
    render json: { error: 'Failed to fetch user', details: e.message }, status: :internal_server_error
  end

  def create
    user = User.new(
      name: params[:name],
      email: params[:email],
      password: params[:password],
      password_confirmation: params[:password_confirmation],
      role: params[:role] || 'agency'
    )

    if user.save
      render json: serialize_user(user), status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  rescue StandardError => e
    render json: { error: 'Failed to create user', details: e.message }, status: :internal_server_error
  end

  def update
    user = User.find_by(id: params[:id])
    unless user
      return render json: { error: 'User not found' }, status: :not_found
    end

    user.assign_attributes(
      name: params[:name] || user.name,
      role: params[:role] || user.role
    )

    if params[:password].present?
      user.password = params[:password]
      user.password_confirmation = params[:password_confirmation]
    end

    if user.save
      render json: serialize_user(user), status: :ok
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  rescue StandardError => e
    render json: { error: 'Failed to update user', details: e.message }, status: :internal_server_error
  end

  private

  def require_admin
    unless current_user.admin?
      render json: { error: 'Forbidden' }, status: :forbidden
    end
  end

  def serialize_user(user)
    {
      id: user.id,
      name: user.name,
      email: user.email,
      role: user.role,
      agency: user.agency ? { id: user.agency.id, name: user.agency.name } : nil,
      created_at: user.created_at,
      updated_at: user.updated_at
    }
  end
end
