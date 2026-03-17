class AgencyStaffingRequest < ApplicationRecord
  belongs_to :event_role
  belongs_to :agency
  belongs_to :requested_by, class_name: "User"
  has_many :agency_staffing_candidates, dependent: :destroy
  has_many :agency_staff_members, through: :agency_staffing_candidates

  enum :status, { pending: 0, declined: 1, submitted: 2, cancelled: 3 }, prefix: true

  validates :vacancies_requested, presence: true,
            numericality: { greater_than: 0, only_integer: true }
  validates :event_role_id, uniqueness: { scope: :agency_id,
            message: "already has a request sent to this agency" }

  def candidates_accepted_count
    agency_staffing_candidates.status_accepted.count
  end

  def candidates_submitted_count
    agency_staffing_candidates.count
  end
end
