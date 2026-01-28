class Agency < ApplicationRecord
  belongs_to :user
  has_many :submissions
  validates :name, presence: true, uniqueness: true
  validates :project_name, presence: true
  validates :ministry, presence: true
  
end
