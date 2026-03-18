class AgencyStaffMember < ApplicationRecord
  belongs_to :agency
  belongs_to :blacklisted_by, class_name: "User", optional: true
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

  scope :active,      -> { where(active: true) }
  scope :ordered,     -> { order(:name) }
  scope :blacklisted, -> { where(blacklisted: true) }

  def blacklist!(by_user:, reason:)
    update!(
      blacklisted:      true,
      blacklisted_at:   Time.current,
      blacklist_reason: reason,
      blacklisted_by:   by_user
    )
  end

  def unblacklist!
    update!(
      blacklisted:      false,
      blacklisted_at:   nil,
      blacklist_reason: nil,
      blacklisted_by:   nil
    )
  end
end
