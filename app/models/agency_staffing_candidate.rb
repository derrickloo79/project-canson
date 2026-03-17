class AgencyStaffingCandidate < ApplicationRecord
  belongs_to :agency_staffing_request
  belongs_to :agency_staff_member

  enum :status, { submitted: 0, accepted: 1, rejected: 2 }, prefix: true

  validates :agency_staffing_request_id, uniqueness: {
    scope: :agency_staff_member_id,
    message: "this staff member has already been submitted for this request"
  }
end
