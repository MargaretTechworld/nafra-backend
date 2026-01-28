class Api::Admin::ChiefdomsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!

  def index
    chiefdoms = Chiefdom.includes(:district).all.order(:name)
    render json: chiefdoms.as_json(include: :district)
  end

  def show
    chiefdom = Chiefdom.includes(:district).find(params[:id])
    render json: chiefdom.as_json(include: :district)
  end

  def create
    chiefdom = Chiefdom.new(chiefdom_params)
    if chiefdom.save
      render json: chiefdom.as_json(include: :district), status: :created
    else
      render json: { errors: chiefdom.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    chiefdom = Chiefdom.find(params[:id])
    if chiefdom.update(chiefdom_params)
      render json: chiefdom.as_json(include: :district)
    else
      render json: { errors: chiefdom.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    chiefdom = Chiefdom.find(params[:id])
    chiefdom.destroy
    head :no_content
  end

  private

  def chiefdom_params
    params.require(:chiefdom).permit(:name, :district_id)
  end

  def require_admin!
    render json: { error: 'Admin access required' }, status: :forbidden unless current_user&.admin?
  end
end
