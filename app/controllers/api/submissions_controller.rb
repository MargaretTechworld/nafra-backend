class Api::SubmissionsController < ApplicationController
  include PaginationHelper
  before_action :authenticate_user!

  def index
    submissions =
      if current_user.admin?
        Submission.includes(:agency, :submitted_by, :submission_items).all
      else
        Submission.includes(:agency, :submitted_by, :submission_items).where(agency: current_user.agency)
      end

    page = params[:page] || 1
    per_page = params[:per_page] || 20
    
    paginated = paginate(submissions, page: page, per_page: per_page)
    
    render json: {
      submissions: paginated[:data].map { |s| SubmissionSerializer.new(s).as_json },
      pagination: paginated[:pagination]
    }, status: :ok
  rescue StandardError => e
    render json: { error: 'Failed to fetch submissions', details: e.message }, status: :internal_server_error
  end

  def create
    agency = find_agency_for_submission
    return if agency.nil?

    submission = Submission.new(
      agency: agency,
      submitted_by: current_user,
      submitted_at: params[:submitted_at] || Date.today
    )

    if submission.save
      items_params = params[:items] || []
      items_params.each do |item|
        submission.submission_items.build(item.permit(:district_id, :chiefdom_id, :fertilizer_id, :dealer_id, :bags_25kg, :bags_50kg))
      end

      if submission.submission_items.all?(&:valid?)
        submission.submission_items.each(&:save!)
        render json: SubmissionSerializer.new(submission).as_json, status: :created
      else
        submission.destroy
        render json: { errors: submission.submission_items.map { |item| item.errors.full_messages }.flatten }, status: :unprocessable_entity
      end
    else
      render json: { errors: submission.errors.full_messages }, status: :unprocessable_entity
    end
  rescue StandardError => e
    render json: { error: 'Failed to create submission', details: e.message }, status: :internal_server_error
  end

  private

  def find_agency_for_submission
    if current_user.admin?
      agency = Agency.find_by(id: params[:agency_id])
      unless agency
        render json: { error: 'Agency not found' }, status: :not_found
        return nil
      end
      agency
    else
      unless current_user.agency
        render json: { error: 'User not associated with any agency' }, status: :forbidden
        return nil
      end
      current_user.agency
    end
  end
end
