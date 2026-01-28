class District < ApplicationRecord
    has_many :chiefdoms

    validates :name, presence: true, uniqueness: true
end
