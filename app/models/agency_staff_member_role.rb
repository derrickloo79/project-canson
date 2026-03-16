class AgencyStaffMemberRole < ApplicationRecord
  belongs_to :agency_staff_member
  belongs_to :role
end