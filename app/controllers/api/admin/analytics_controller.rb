class Api::Admin::AnalyticsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin

  def bags_by_district
    bags_25kg_data = SubmissionItem
                      .joins(:district)
                      .group('districts.name')
                      .sum('bags_25kg')

    bags_50kg_data = SubmissionItem
                      .joins(:district)
                      .group('districts.name')
                      .sum('bags_50kg')

    data = bags_25kg_data.map do |district, count_25kg|
      {
        district: district,
        bags_25kg: count_25kg,
        bags_50kg: bags_50kg_data[district] || 0
      }
    end

    render json: data, status: :ok
  rescue StandardError => e
    render json: { error: 'Failed to fetch district analytics', details: e.message }, status: :internal_server_error
  end

  def bags_by_agency
    bags_25kg_data = SubmissionItem
                      .joins(submission: :agency)
                      .group('agencies.name')
                      .sum('bags_25kg')

    bags_50kg_data = SubmissionItem
                      .joins(submission: :agency)
                      .group('agencies.name')
                      .sum('bags_50kg')

    data = bags_25kg_data.map do |agency, count_25kg|
      {
        agency: agency,
        bags_25kg: count_25kg,
        bags_50kg: bags_50kg_data[agency] || 0
      }
    end

    render json: data, status: :ok
  rescue StandardError => e
    render json: { error: 'Failed to fetch agency analytics', details: e.message }, status: :internal_server_error
  end

  def bags_by_fertilizer
    bags_25kg_data = SubmissionItem
                      .joins(:fertilizer)
                      .group('fertilizers.name')
                      .sum('bags_25kg')

    bags_50kg_data = SubmissionItem
                      .joins(:fertilizer)
                      .group('fertilizers.name')
                      .sum('bags_50kg')

    data = bags_25kg_data.map do |fertilizer, count_25kg|
      {
        fertilizer: fertilizer,
        bags_25kg: count_25kg,
        bags_50kg: bags_50kg_data[fertilizer] || 0
      }
    end

    render json: data, status: :ok
  rescue StandardError => e
    render json: { error: 'Failed to fetch fertilizer analytics', details: e.message }, status: :internal_server_error
  end

  def agency_district_distribution
    # Get agency_id and district_id from query parameters
    agency_id = params[:agency_id]
    district_id = params[:district_id]

    # Validate parameters
    unless agency_id && district_id
      return render json: { error: 'agency_id and district_id parameters are required' }, status: :bad_request
    end

    # Verify agency exists
    agency = Agency.find_by(id: agency_id)
    unless agency
      return render json: { error: 'Agency not found' }, status: :not_found
    end

    # Verify district exists
    district = District.find_by(id: district_id)
    unless district
      return render json: { error: 'District not found' }, status: :not_found
    end

    # Get distribution data for agency in specific district
    data = SubmissionItem
            .joins(submission: :agency)
            .joins(:district)
            .joins(:chiefdom)
            .joins(:fertilizer)
            .where(submissions: { agency_id: agency_id })
            .where(submission_items: { district_id: district_id })
            .select('fertilizers.name, chiefdoms.name as chiefdom_name, submission_items.bags_25kg, submission_items.bags_50kg')
            .map do |item|
      {
        fertilizer: item.fertilizer.name,
        chiefdom: item.chiefdom.name,
        bags_25kg: item.bags_25kg,
        bags_50kg: item.bags_50kg
      }
    end

    # Calculate totals
    total_bags_25kg = data.sum { |item| item[:bags_25kg] }
    total_bags_50kg = data.sum { |item| item[:bags_50kg] }

    render json: {
      agency: {
        id: agency.id,
        name: agency.name
      },
      district: {
        id: district.id,
        name: district.name
      },
      distributions: data,
      totals: {
        total_bags_25kg: total_bags_25kg,
        total_bags_50kg: total_bags_50kg
      }
    }, status: :ok
  rescue StandardError => e
    render json: { error: 'Failed to fetch agency-district distribution', details: e.message }, status: :internal_server_error
  end

  private

  def require_admin
    unless current_user.admin?
      render json: { error: 'Forbidden' }, status: :forbidden
    end
  end
end
