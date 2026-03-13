class StaffMemberRole < ApplicationRecord
  belongs_to :staff_member
  belongs_to :role
end