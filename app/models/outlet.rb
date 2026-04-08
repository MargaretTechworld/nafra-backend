class Outlet < ApplicationRecord
  belongs_to :dealer
  belongs_to :region, optional: true
  belongs_to :district, optional: true
  belongs_to :chiefdom, optional: true

  validates :address, presence: true
end
