class AddBlacklistToAgencyStaffMembers < ActiveRecord::Migration[8.1]
  def change
    add_column :agency_staff_members, :blacklisted, :boolean, default: false, null: false
    add_column :agency_staff_members, :blacklisted_at, :datetime
    add_column :agency_staff_members, :blacklist_reason, :text
    add_column :agency_staff_members, :blacklisted_by_id, :integer
  end
end
