class Api::Admin::DistrictsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!

  def index
    districts = District.all.order(:name)
    render json: districts
  end

  def show
    district = District.find(params[:id])
    render json: district
  end

  def create
    district = District.new(district_params)
    if district.save
      render json: district, status: :created
    else
      render json: { errors: district.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    district = District.find(params[:id])
    if district.update(district_params)
      render json: district
    else
      render json: { errors: district.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    district = District.find(params[:id])
    district.destroy
    head :no_content
  end

  private

  def district_params
    params.require(:district).permit(:name)
  end

  def require_admin!
    render json: { error: 'Admin access required' }, status: :forbidden unless current_user&.admin?
  end
end
