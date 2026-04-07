class ContactPerson < ApplicationRecord
  belongs_to :dealer

  validates :name, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  
  before_save :ensure_single_primary

  private

  def ensure_single_primary
    if is_primary
      dealer.contact_people.where.not(id: id).update_all(is_primary: false)
    end
  end
end
