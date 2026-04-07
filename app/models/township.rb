class Township < ApplicationRecord
  belongs_to :chiefdom
  has_many :outlets, dependent: :destroy

  validates :name, presence: true
  validates :name, uniqueness: { scope: :chiefdom_id }
end
