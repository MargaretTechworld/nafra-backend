class Draft < ApplicationRecord
  belongs_to :user
  
  validates :title, presence: true
  validates :status, presence: true, inclusion: { in: ['draft', 'submitted'] }
  validate :validate_data_structure
  
  serialize :data, coder: JSON
  
  scope :by_user, ->(user_id) { where(user_id: user_id) }
  scope :drafts, -> { where(status: 'draft') }
  scope :submitted, -> { where(status: 'submitted') }
  
  before_create :set_default_values
  
  # Public method to submit a draft and create a submission
  def submit!(user)
    agency = user.agency
    
    unless agency
      errors.add(:base, "User does not belong to an agency")
      raise ActiveRecord::RecordInvalid.new(self)
    end

    unless data.is_a?(Hash) || data.is_a?(Array)
      errors.add(:data, "must be a valid data structure (list or object)")
      raise ActiveRecord::RecordInvalid.new(self)
    end

    ActiveRecord::Base.transaction do
      # 1. Create Submission
      submission = Submission.create!(
        agency: agency,
        submitted_by: user,
        submitted_at: Time.current
      )

      # 2. Extract and Aggregate Items from data
      aggregated_items = {} # Key: [chiefdom_id, fertilizer_id, dealer_id] -> { data }
      
      if data.is_a?(Hash) && data['districts'].is_a?(Array)
        data['districts'].each do |district_data|
          district_name = district_data['district'] || district_data['name']
          district = District.find_by(name: district_name)
          next unless district

          district_data['chiefdoms']&.each do |chiefdom_data|
            chiefdom_name = chiefdom_data['name']
            chiefdom = district.chiefdoms.find_by(name: chiefdom_name)
            next unless chiefdom

            chiefdom_data['fertilizers']&.each do |fert_data|
              fertilizer = Fertilizer.find_by(name: fert_data['name'])
              dealer = Dealer.find_by(id: fert_data['dealership'] || fert_data['dealer_id'])
              next unless fertilizer && dealer

              # Grouping Key
              key = [chiefdom.id, fertilizer.id, dealer.id]
              aggregated_items[key] ||= {
                submission_id: submission.id,
                district_id: district.id,
                chiefdom_id: chiefdom.id,
                fertilizer_id: fertilizer.id,
                dealer_id: dealer.id,
                bags_25kg: 0,
                bags_50kg: 0
              }

              # Add bag counts (handling both split and combined formats)
              if fert_data['bagSize'].present? && fert_data['bagCount'].present?
                count = fert_data['bagCount'].to_i
                if fert_data['bagSize'].to_s == '25'
                  aggregated_items[key][:bags_25kg] += count
                elsif fert_data['bagSize'].to_s == '50'
                  aggregated_items[key][:bags_50kg] += count
                end
              else
                aggregated_items[key][:bags_25kg] += fert_data['bag25kg'].to_i
                aggregated_items[key][:bags_50kg] += fert_data['bag50kg'].to_i
              end
            end
          end
        end
        
        # 3. Bulk Create aggregated records
        final_items = aggregated_items.values.select { |item| item[:bags_25kg] > 0 || item[:bags_50kg] > 0 }
        SubmissionItem.insert_all!(final_items) if final_items.any?
      elsif data.is_a?(Array)
        # Handle flat array format if provided
        SubmissionItem.insert_all!(data.map { |d| d.merge(submission_id: submission.id) }) if data.any?
      end

      # 4. Destroy the Draft after successful submission
      destroy!
      
      submission
    end
  end
  
  private
  
  def validate_data_structure
    return if data.blank?
    
    unless data.is_a?(Array) || data.is_a?(Hash)
      errors.add(:data, "must be a list of items or a nested object structure")
      return
    end

    if data.is_a?(Array)
      data.each_with_index do |item, index|
        if item['district_id'].present? && item['chiefdom_id'].blank?
          errors.add(:data, "item at index #{index} is missing chiefdom_id (required when district_id is present)")
        end
      end
    end
  end

  def set_default_values
    self.status ||= 'draft'
  end
end
