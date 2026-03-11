class EventRole < ApplicationRecord
  belongs_to :event

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
