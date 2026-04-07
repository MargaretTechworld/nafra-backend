class User < ApplicationRecord
  has_secure_password

  enum role: { admin: 'admin', agency: 'agency' }

  has_one :agency
  has_many :drafts, dependent: :destroy
  has_many :submissions, dependent: :destroy

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :role, presence: true, inclusion: { in: %w[admin agency] }    
  validates :password, presence: true, length: { minimum: 8 }, if: :password_required? 
  
    private
    def password_required?
      new_record? || password.present?
    end
end
