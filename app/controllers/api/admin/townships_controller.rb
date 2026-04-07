class Api::Admin::TownshipsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!

  def index
    townships = Township.all.includes(:chiefdom).order(:name)
    render json: townships, include: :chiefdom
  end

  def show
    township = Township.find(params[:id])
    render json: township, include: :chiefdom
  end

  def create
    township = Township.new(township_params)
    if township.save
      render json: township, include: :chiefdom, status: :created
    else
      render json: { errors: township.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    township = Township.find(params[:id])
    if township.update(township_params)
      render json: township, include: :chiefdom
    else
      render json: { errors: township.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    township = Township.find(params[:id])
    township.destroy
    head :no_content
  end

  private

  def township_params
    params.require(:township).permit(:name, :chiefdom_id)
  end

  def require_admin!
    render json: { error: 'Admin access required' }, status: :forbidden unless current_user&.admin?
  end
end
