class Api::Admin::AgenciesController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin

  def index
    agencies = Agency.all
    render json: agencies.map { |a| serialize_agency(a) }, status: :ok
  rescue StandardError => e
    render json: { error: 'Failed to fetch agencies', details: e.message }, status: :internal_server_error
  end

  def show
    agency = Agency.find_by(id: params[:id])
    unless agency
      return render json: { error: 'Agency not found' }, status: :not_found
    end

    render json: serialize_agency(agency), status: :ok
  rescue StandardError => e
    render json: { error: 'Failed to fetch agency', details: e.message }, status: :internal_server_error
  end

  def create
    # Verify user exists
    user = User.find_by(id: params[:user_id])
    unless user
      return render json: { error: 'User not found' }, status: :not_found
    end

    # Verify user is an agency user
    unless user.agency?
      return render json: { error: 'User must have agency role' }, status: :bad_request
    end

    # Verify user doesn't already have an agency
    if user.agency
      return render json: { error: 'User already has an associated agency' }, status: :bad_request
    end

    agency = Agency.new(
      name: params[:name],
      project_name: params[:project_name],
      ministry: params[:ministry],
      user_id: params[:user_id]
    )

    if agency.save
      render json: serialize_agency(agency), status: :created
    else
      render json: { errors: agency.errors.full_messages }, status: :unprocessable_entity
    end
  rescue StandardError => e
    render json: { error: 'Failed to create agency', details: e.message }, status: :internal_server_error
  end

  def update
    agency = Agency.find_by(id: params[:id])
    unless agency
      return render json: { error: 'Agency not found' }, status: :not_found
    end

    agency.assign_attributes(
      name: params[:name] || agency.name,
      project_name: params[:project_name] || agency.project_name,
      ministry: params[:ministry] || agency.ministry
    )

    if agency.save
      render json: serialize_agency(agency), status: :ok
    else
      render json: { errors: agency.errors.full_messages }, status: :unprocessable_entity
    end
  rescue StandardError => e
    render json: { error: 'Failed to update agency', details: e.message }, status: :internal_server_error
  end

  private

  def require_admin
    unless current_user.admin?
      render json: { error: 'Forbidden' }, status: :forbidden
    end
  end

  def serialize_agency(agency)
    {
      id: agency.id,
      name: agency.name,
      project_name: agency.project_name,
      ministry: agency.ministry,
      user: {
        id: agency.user.id,
        name: agency.user.name,
        email: agency.user.email
      },
      created_at: agency.created_at,
      updated_at: agency.updated_at
    }
  end
end
