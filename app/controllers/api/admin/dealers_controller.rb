class Api::Admin::DealersController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!

  def index
    dealers = Dealer.all.order(:name)
    render json: dealers
  end

  def show
    dealer = Dealer.find(params[:id])
    render json: dealer
  end

  def create
    dealer = Dealer.new(dealer_params)
    if dealer.save
      render json: dealer, status: :created
    else
      render json: { errors: dealer.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    dealer = Dealer.find(params[:id])
    if dealer.update(dealer_params)
      render json: dealer
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
    params.require(:dealer).permit(:name, :license_number, :status)
  end

  def require_admin!
    render json: { error: 'Admin access required' }, status: :forbidden unless current_user&.admin?
  end
end
