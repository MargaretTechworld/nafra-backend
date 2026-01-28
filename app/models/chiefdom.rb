class Chiefdom < ApplicationRecord
  belongs_to :district
  validates :name, presence: true, uniqueness: true
end
