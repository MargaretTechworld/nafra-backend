class Api::ReferenceController < ApplicationController
  # Only require authentication for POST endpoints (creating data)
  before_action :authenticate_user!, only: [:create_district, :create_chiefdom, :create_fertilizer, :create_dealer]
  
  # Districts
  def districts
    districts = District.select(:id, :name).order(:name)
    render json: districts
  end
  
  def create_district
    return render json: { error: 'Only admins can create districts' }, status: :forbidden unless current_user.admin?
    
    district = District.new(district_params)
    if district.save
      render json: district, status: :created
    else
      render json: { errors: district.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # Chiefdoms
  def chiefdoms
    chiefdoms = if params[:district_id]
                  Chiefdom.where(district_id: params[:district_id]).select(:id, :name, :district_id).order(:name)
                else
                  Chiefdom.select(:id, :name, :district_id).includes(:district).order(:name)
                end
    render json: chiefdoms, include: :district
  end
  
  def create_chiefdom
    return render json: { error: 'Only admins can create chiefdoms' }, status: :forbidden unless current_user.admin?
    
    chiefdom = Chiefdom.new(chiefdom_params)
    if chiefdom.save
      render json: chiefdom, status: :created
    else
      render json: { errors: chiefdom.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # Fertilizers
  def fertilizers
    fertilizers = Fertilizer.select(:id, :name).order(:name)
    render json: fertilizers
  end
  
  def create_fertilizer
    return render json: { error: 'Only admins can create fertilizers' }, status: :forbidden unless current_user.admin?
    
    fertilizer = Fertilizer.new(fertilizer_params)
    if fertilizer.save
      render json: fertilizer, status: :created
    else
      render json: { errors: fertilizer.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # Dealers (Admin only for creation)
  def dealers
    dealers = Dealer.select(:id, :name, :license_number, :status).where(status: 'active').order(:name)
    render json: dealers
  end
  
  def regions
    regions = Region.select(:id, :name).order(:name)
    render json: regions
  end

  def create_dealer
    return render json: { error: 'Only admins can create dealers' }, status: :forbidden unless current_user.admin?
    
    dealer = Dealer.new(dealer_params)
    if dealer.save
      render json: dealer, status: :created
    else
      render json: { errors: dealer.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def create_region
    return render json: { error: 'Only admins can create regions' }, status: :forbidden unless current_user&.admin?
    
    region = Region.new(region_params)
    if region.save
      render json: region, status: :created
    else
      render json: { errors: region.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def region_params
    params.require(:region).permit(:name)
  end

  def district_params
    params.require(:district).permit(:name, :region_id)
  end

  def chiefdom_params
    params.require(:chiefdom).permit(:name, :district_id)
  end

  def fertilizer_params
    params.require(:fertilizer).permit(:name)
  end

  def dealer_params
    params.require(:dealer).permit(:name, :license_number, :status)
  end
end
