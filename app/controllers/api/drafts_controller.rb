class Api::DraftsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_draft, only: [:show, :update, :destroy, :submit]

  # GET /api/drafts
  def index
    @drafts = current_user.drafts.drafts.includes(:user).order(updated_at: :desc)
    render json: @drafts, include: :user
  end

  # GET /api/drafts/:id
  def show
    render json: @draft, include: :user
  end

  # POST /api/drafts
  def create
    Rails.logger.info "📝 Creating new draft for user #{current_user.id}"
    @draft = current_user.drafts.build(draft_params)
    
    if @draft.save
      Rails.logger.info "✅ Draft created successfully - ID: #{@draft.id}, Title: #{@draft.title}"
      Rails.logger.info "   Districts count: #{@draft.data&.dig('districts')&.length || 0}"
      render json: @draft, include: :user, status: :created
    else
      Rails.logger.error "❌ Failed to create draft: #{@draft.errors.full_messages.join(', ')}"
      render json: { errors: @draft.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PUT /api/drafts/:id
  def update
    Rails.logger.info "📝 Updating draft #{@draft.id} for user #{current_user.id}"
    Rails.logger.info "   Current districts: #{@draft.data&.dig('districts')&.length || 0}"
    
    if @draft.update(draft_params)
      Rails.logger.info "✅ Draft updated successfully - ID: #{@draft.id}"
      Rails.logger.info "   New districts count: #{@draft.data&.dig('districts')&.length || 0}"
      render json: @draft, include: :user
    else
      Rails.logger.error "❌ Failed to update draft: #{@draft.errors.full_messages.join(', ')}"
      render json: { errors: @draft.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /api/drafts/:id
  def destroy
    if @draft.destroy
      head :no_content
    else
      render json: { errors: ['Failed to delete draft'] }, status: :unprocessable_entity
    end
  end

  # POST /api/drafts/:id/submit
  def submit
    Rails.logger.info "📤 Submitting draft #{@draft.id} for user #{current_user.id}"
    
    if @draft.status == 'draft'
      begin
        @submission = @draft.submit!(current_user)
        
        Rails.logger.info "✅ Draft submitted successfully - Submission ID: #{@submission.id}"
        
        render json: {
          message: 'Draft submitted successfully',
          submission: @submission,
          draft: @draft
        }
      rescue ActiveRecord::RecordInvalid => e
        Rails.logger.error "❌ Failed to submit draft: #{e.record.errors.full_messages.join(', ')}"
        render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
      rescue => e
        Rails.logger.error "❌ Failed to submit draft: #{e.message}"
        render json: { errors: [e.message] }, status: :unprocessable_entity
      end
    else
      Rails.logger.warn "⚠️  Draft #{@draft.id} has already been submitted"
      render json: { errors: ['Draft has already been submitted'] }, status: :unprocessable_entity
    end
  end

  private

  def set_draft
    @draft = current_user.drafts.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { errors: ['Draft not found'] }, status: :not_found
  end

  def draft_params
    params.require(:draft).permit(:title, :status, data: {}).tap do |whitelisted|
      if params[:draft][:data].is_a?(ActionController::Parameters)
        whitelisted[:data] = params[:draft][:data].permit!
      end
    end
  end
end
