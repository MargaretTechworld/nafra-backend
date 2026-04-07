class District < ApplicationRecord
    belongs_to :region, optional: true
    has_many :chiefdoms
    has_many :outlets

    validates :name, presence: true, uniqueness: true
end
