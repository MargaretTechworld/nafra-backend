class Dealer < ApplicationRecord
    has_many :contact_people, dependent: :destroy
    has_many :outlets, dependent: :destroy
    
    accepts_nested_attributes_for :contact_people, allow_destroy: true
    accepts_nested_attributes_for :outlets, allow_destroy: true

    enum status: { active: "active", inactive: "inactive" } 
    
    validates :name, presence: true, uniqueness: true
    validates :status, presence: true
    validates :category, presence: true
    validates :licensing_status, inclusion: { in: ["Active", "Not Licensed"] }

    def expired?
      return false unless license_expiry_date
      license_expiry_date < Date.current
    end

    def current_licensing_status
      return "Expired" if expired?
      licensing_status
    end
end
