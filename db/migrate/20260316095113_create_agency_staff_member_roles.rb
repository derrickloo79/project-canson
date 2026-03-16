class CreateAgencyStaffMemberRoles < ActiveRecord::Migration[8.1]
  def change
    create_table :agency_staff_member_roles do |t|
      t.references :agency_staff_member, null: false, foreign_key: true
      t.references :role, null: false, foreign_key: true

      t.timestamps
    end
    add_index :agency_staff_member_roles, [ :agency_staff_member_id, :role_id ], unique: true
  end
end
