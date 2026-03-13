class EventInvitation < ApplicationRecord
  belongs_to :event_role
  belongs_to :staff_member

  enum :status, { pending: 0, accepted: 1, declined: 2 }, prefix: true

  validates :event_role_id, uniqueness: {
    scope: :staff_member_id,
    message: "this staff member has already been invited to this role"
  }

  scope :ordered_for_staff, -> { order(created_at: :desc) }

  def responded?
    status_accepted? || status_declined?
  end
end
