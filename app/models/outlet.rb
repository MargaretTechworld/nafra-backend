class Outlet < ApplicationRecord
  belongs_to :dealer
  belongs_to :region
  belongs_to :district
  belongs_to :chiefdom
  belongs_to :township

  validates :address, presence: true
end
