class Agency < ApplicationRecord
  belongs_to :invited_by, class_name: "User"
  has_one    :agency_connection, dependent: :destroy
  has_many   :users, dependent: :nullify

  validates :name,            presence: true
  validates :contact_email,   presence: true,
                              format: { with: URI::MailTo::EMAIL_REGEXP },
                              uniqueness: { case_sensitive: false }
  validates :invitation_token, presence: true, uniqueness: true

  before_validation :generate_token, on: :create

  def registered?
    invitation_accepted_at.present?
  end

  private

  def generate_token
    self.invitation_token ||= SecureRandom.urlsafe_base64(32)
  end
end
