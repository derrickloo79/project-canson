class StaffMember < ApplicationRecord
  enum :gender, {
    male:             0,
    female:           1,
    non_binary:       2,
    prefer_not_to_say: 3
  }, prefix: true

  has_many :staff_member_roles, dependent: :destroy
  has_many :roles, through: :staff_member_roles
  has_many :event_invitations, dependent: :destroy

  belongs_to :user, optional: true
  belongs_to :blacklisted_by, class_name: "User", optional: true

  validates :name,  presence: true
  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }

  def has_login?
    user_id.present?
  end

  scope :ordered,      -> { order(:name) }
  scope :blacklisted,  -> { where(blacklisted: true) }
  scope :active,       -> { where(active: true, blacklisted: false) }

  def blacklist!(by_user:, reason:)
    update!(
      blacklisted:       true,
      blacklisted_at:    Time.current,
      blacklist_reason:  reason,
      blacklisted_by:    by_user
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
