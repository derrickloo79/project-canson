class CreateAgencyStaffMembers < ActiveRecord::Migration[8.1]
  def change
    create_table :agency_staff_members do |t|
      t.references :agency, null: false, foreign_key: true
      t.string  :name,   null: false
      t.string  :email,  null: false
      t.string  :mobile
      t.integer :gender
      t.boolean :active, null: false, default: true

      t.timestamps
    end
    add_index :agency_staff_members, [ :agency_id, :email ], unique: true
  end
end
