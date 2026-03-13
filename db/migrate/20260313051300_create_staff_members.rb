class CreateStaffMembers < ActiveRecord::Migration[8.1]
  def change
    create_table :staff_members do |t|
      t.string   :name,             null: false
      t.string   :email,            null: false
      t.string   :mobile
      t.integer  :gender
      t.boolean  :blacklisted,      default: false, null: false
      t.datetime :blacklisted_at
      t.text     :blacklist_reason
      t.integer  :blacklisted_by_id

      t.timestamps
    end

    add_index :staff_members, :email, unique: true
    add_foreign_key :staff_members, :users, column: :blacklisted_by_id
  end
end
