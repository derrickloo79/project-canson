class CreateStaffMemberRoles < ActiveRecord::Migration[8.1]
  def change
    create_table :staff_member_roles do |t|
      t.integer :staff_member_id, null: false
      t.integer :role_id,         null: false

      t.timestamps
    end

    add_index :staff_member_roles, [ :staff_member_id, :role_id ], unique: true
    add_foreign_key :staff_member_roles, :staff_members
    add_foreign_key :staff_member_roles, :roles
  end
end