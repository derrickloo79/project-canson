class EventRole < ApplicationRecord
  belongs_to :event
  has_many :event_invitations, dependent: :destroy
  has_many :invited_staff_members, through: :event_invitations, source: :staff_member

  def confirmed_count
    event_invitations.status_accepted.count
  end

  # Returns true if this role's shift overlaps with other_role's shift.
  # Times are compared as seconds-since-midnight; next-day end adds 86 400 s.
  def clashes_with?(other_role)
    a_start = shift_start.seconds_since_midnight
    a_end   = shift_end.seconds_since_midnight + (shift_end_next_day? ? 86_400 : 0)
    b_start = other_role.shift_start.seconds_since_midnight
    b_end   = other_role.shift_end.seconds_since_midnight + (other_role.shift_end_next_day? ? 86_400 : 0)
    a_start < b_end && b_start < a_end
  end

  validates :role_name, presence: true
  validates :vacancies, presence: true,
            numericality: { greater_than: 0, only_integer: true }
  validates :shift_start, :shift_end, presence: true
  validate :shift_end_after_shift_start

  private

  def shift_end_after_shift_start
    return unless shift_start && shift_end
    return if shift_end_next_day?
    errors.add(:shift_end, "must be after shift start") if shift_end <= shift_start
  end
end
