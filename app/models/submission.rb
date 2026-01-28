class Submission < ApplicationRecord
  belongs_to :agency
  belongs_to :submitted_by, class_name: "User", foreign_key: "submitted_by_id"
  has_many :submission_items, dependent: :destroy

  validates :agency, :submitted_by, presence: true
  validates :submitted_at, presence: true
  validate :submitted_at_cannot_be_in_future
  validate :user_agency_authorization

  private

  def submitted_at_cannot_be_in_future
    if submitted_at.present? && submitted_at > Date.today
      errors.add(:submitted_at, "cannot be in the future")
    end
  end

  def user_agency_authorization
    if submitted_by.present? && submitted_by.agency.present? && agency.present?
      unless submitted_by.admin? || submitted_by.agency == agency
        errors.add(:agency, "can only submit for their own agency")
      end
    end
  end
end
