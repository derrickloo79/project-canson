class AddActiveToStaffMembers < ActiveRecord::Migration[8.1]
  def change
    add_column :staff_members, :active, :boolean, default: true, null: false
  end
end
