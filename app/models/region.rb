class Region < ApplicationRecord
  has_many :districts, dependent: :nullify
  has_many :outlets, dependent: :destroy

  validates :name, presence: true, uniqueness: true
end
