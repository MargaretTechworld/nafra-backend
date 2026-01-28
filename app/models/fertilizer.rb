class Fertilizer < ApplicationRecord
    validates :name, presence: true, uniqueness: true
end
