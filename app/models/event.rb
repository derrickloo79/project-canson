class Event < ApplicationRecord
  belongs_to :user
  has_many :event_roles, -> { order(position: :asc) }, dependent: :destroy
  accepts_nested_attributes_for :event_roles,
                                allow_destroy: true,
                                reject_if: :all_blank

  enum :event_type, {
    wedding_dinner:   0,
    conference:       1,
    corporate_event:  2,
    gala:             3,
    private_function: 4,
    other:            5
  }, prefix: true

  enum :status, {
    draft:            0,
    pending_approval: 1,
    rejected:         2,
    approved:         3,
    invitation_open:  4,
    fully_staffed:    5,
    ongoing:          6,
    ended:            7,
    cancelled:        8
  }, prefix: true

  # Always required
  validates :event_name, presence: true

  # Required once the user advances past step 1
  validates :event_date, :venue, :event_type,
            :event_start_time, :event_end_time,
            presence: true, if: :validate_step2_or_beyond?

  validates :event_end_date, presence: true,
            if: -> { validate_step2_or_beyond? && multi_day? }

  # Required before final submission
  validate :must_have_at_least_one_role, if: :validate_step3?

  def validate_step2_or_beyond?
    wizard_step.to_i >= 2
  end

  def validate_step3?
    wizard_step.to_i >= 3
  end

  def must_have_at_least_one_role
    if event_roles.reject(&:marked_for_destruction?).empty?
      errors.add(:base, "You must add at least one role before submitting.")
    end
  end

  # Summary helpers used by the Step 2 panel
  def total_vacancies
    event_roles.sum(:vacancies)
  end

  def earliest_shift_start
    event_roles.minimum(:shift_start)
  end

  def latest_shift_end
    event_roles.maximum(:shift_end)
  end

  def event_days
    return 1 unless multi_day? && event_date && event_end_date

    (event_end_date - event_date).to_i + 1
  end

  def estimated_total_cost
    days = event_days
    event_roles.sum do |role|
      next 0 unless role.rate && role.shift_start && role.shift_end && role.vacancies

      seconds = role.shift_end - role.shift_start
      seconds += 24 * 3600 if role.shift_end_next_day?
      hours = seconds / 3600.0
      role.vacancies * role.rate * hours * days
    end
  end
end
