class SubmissionItem < ApplicationRecord
  belongs_to :submission
  belongs_to :district
  belongs_to :chiefdom
  belongs_to :fertilizer
  belongs_to :dealer

  validates :submission, :district, :chiefdom, :fertilizer, :dealer, presence: true
  validates :bags_25kg, :bags_50kg, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate :at_least_one_bag_present

  private

  def at_least_one_bag_present
    if bags_25kg.to_i.zero? && bags_50kg.to_i.zero?
      errors.add(:base, "At least one bag size must be provided")
    end
  end
end
