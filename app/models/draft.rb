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

      # 2. Create SubmissionItems from data
      # If data is nested (frontend format), we need to flatten it
      items_to_create = []
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
              fert_name = fert_data['name']
              fertilizer = Fertilizer.find_by(name: fert_name)
              dealer_id = fert_data['dealership']
              dealer = Dealer.find_by(id: dealer_id)

              next unless fertilizer && dealer

              # Handle both formats: 
              # 1. Frontend format: {bagSize: "25", bagCount: 7}
              # 2. Legacy format: {bag25kg: 7, bag50kg: 7}
              if fert_data['bagSize'].present? && fert_data['bagCount'].present?
                # Frontend format - already split by bag size
                bag_size = fert_data['bagSize'].to_s
                bag_count = fert_data['bagCount'].to_i
                
                next if bag_count <= 0
                
                items_to_create << {
                  district_id: district.id,
                  chiefdom_id: chiefdom.id,
                  fertilizer_id: fertilizer.id,
                  dealer_id: dealer.id,
                  bags_25kg: bag_size == '25' ? bag_count : 0,
                  bags_50kg: bag_size == '50' ? bag_count : 0
                }
              else
                # Legacy format - combined bag sizes
                bags_25 = fert_data['bag25kg'].to_i
                bags_50 = fert_data['bag50kg'].to_i
                
                next if bags_25 <= 0 && bags_50 <= 0
                
                items_to_create << {
                  district_id: district.id,
                  chiefdom_id: chiefdom.id,
                  fertilizer_id: fertilizer.id,
                  dealer_id: dealer.id,
                  bags_25kg: bags_25,
                  bags_50kg: bags_50
                }
              end
            end
          end
        end
      elsif data.is_a?(Array)
        items_to_create = data
      end

      if items_to_create.empty?
        errors.add(:data, "contains no valid distribution records to submit")
        raise ActiveRecord::Rollback
      end

      items_to_create.each do |item_data|
        submission.submission_items.create!(
          district_id: item_data[:district_id] || item_data['district_id'],
          chiefdom_id: item_data[:chiefdom_id] || item_data['chiefdom_id'],
          fertilizer_id: item_data[:fertilizer_id] || item_data['fertilizer_id'],
          dealer_id: item_data[:dealer_id] || item_data['dealer_id'],
          bags_25kg: item_data[:bags_25kg] || item_data['bags_25kg'].to_i,
          bags_50kg: item_data[:bags_50kg] || item_data['bags_50kg'].to_i
        )
      end

      # 3. Destroy the Draft after successful submission
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
