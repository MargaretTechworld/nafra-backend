class Dealer < ApplicationRecord
    enum status: { active: "active", inactive: "inactive" } 
    validates :name, presence: true, uniqueness: true
    validates :status, presence: true
end
