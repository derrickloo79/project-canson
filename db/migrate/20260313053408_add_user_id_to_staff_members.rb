class AddUserIdToStaffMembers < ActiveRecord::Migration[8.1]
  def change
    add_column :staff_members, :user_id, :integer
    add_index :staff_members, :user_id, unique: true
    add_foreign_key :staff_members, :users
  end
end
