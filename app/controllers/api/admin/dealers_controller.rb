class Api::Admin::DealersController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!

  def index
    dealers = Dealer.all.includes(:contact_people, :outlets).order(:name)
    render json: dealers, include: [:contact_people, :outlets]
  end

  def show
    dealer = Dealer.find(params[:id])
    render json: dealer, include: [:contact_people, :outlets]
  end

  def create
    dealer = Dealer.new(dealer_params)
    if dealer.save
      render json: dealer, include: [:contact_people, :outlets], status: :created
    else
      render json: { errors: dealer.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    dealer = Dealer.find(params[:id])
    if dealer.update(dealer_params)
      render json: dealer, include: [:contact_people, :outlets]
    else
      render json: { errors: dealer.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    dealer = Dealer.find(params[:id])
    dealer.destroy
    head :no_content
  end

  private

  def dealer_params
    params.require(:dealer).permit(
      :name, :license_number, :status, :category, :category_type, 
      :head_office_address, :ceo_name, :registration_date, :license_expiry_date, :licensing_status,
      contact_people_attributes: [:id, :name, :phone, :email, :role, :is_primary, :_destroy],
      outlets_attributes: [:id, :address, :region_id, :district_id, :chiefdom_id, :township_id, :_destroy]
    )
  end

  def require_admin!
    render json: { error: 'Admin access required' }, status: :forbidden unless current_user&.admin?
  end
end
