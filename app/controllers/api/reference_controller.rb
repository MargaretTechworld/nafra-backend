class Api::ReferenceController < ApplicationController
  before_action :authenticate_user!

  def districts
    districts = District.select(:id, :name).order(:name)
    render json: districts
  end

  def chiefdoms
    chiefdoms = Chiefdom.select(:id, :name, :district_id).order(:name)
    render json: chiefdoms
  end

  def fertilizers
    fertilizers = Fertilizer.select(:id, :name).order(:name)
    render json: fertilizers
  end

  def dealers
    dealers = Dealer.select(:id, :name, :license_number, :status).order(:name)
    render json: dealers
  end
end
