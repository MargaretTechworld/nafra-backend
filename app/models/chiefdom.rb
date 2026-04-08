class Chiefdom < ApplicationRecord
  belongs_to :district, optional: true
  validates :name, presence: true, uniqueness: true
end
