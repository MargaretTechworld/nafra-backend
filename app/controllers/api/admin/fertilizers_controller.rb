class Api::Admin::FertilizersController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!

  def index
    fertilizers = Fertilizer.all.order(:name)
    render json: fertilizers
  end

  def show
    fertilizer = Fertilizer.find(params[:id])
    render json: fertilizer
  end

  def create
    fertilizer = Fertilizer.new(fertilizer_params)
    if fertilizer.save
      render json: fertilizer, status: :created
    else
      render json: { errors: fertilizer.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    fertilizer = Fertilizer.find(params[:id])
    if fertilizer.update(fertilizer_params)
      render json: fertilizer
    else
      render json: { errors: fertilizer.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    fertilizer = Fertilizer.find(params[:id])
    fertilizer.destroy
    head :no_content
  end

  private

  def fertilizer_params
    params.require(:fertilizer).permit(:name)
  end

  def require_admin!
    render json: { error: 'Admin access required' }, status: :forbidden unless current_user&.admin?
  end
end
