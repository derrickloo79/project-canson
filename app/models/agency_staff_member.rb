class AgencyStaffMember < ApplicationRecord
  belongs_to :agency
  has_many :agency_staff_member_roles, dependent: :destroy
  has_many :roles, through: :agency_staff_member_roles

  enum :gender, {
    male:              0,
    female:            1,
    non_binary:        2,
    prefer_not_to_say: 3
  }, prefix: true

  validates :name,  presence: true
  validates :email, presence: true,
                    format: { with: URI::MailTo::EMAIL_REGEXP },
                    uniqueness: { scope: :agency_id, case_sensitive: false }

  scope :active,  -> { where(active: true) }
  scope :ordered, -> { order(:name) }
end