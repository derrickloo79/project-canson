class CreateEventInvitations < ActiveRecord::Migration[8.1]
  def change
    create_table :event_invitations do |t|
      t.integer  :event_role_id,   null: false
      t.integer  :staff_member_id, null: false
      t.integer  :status,          null: false, default: 0
      t.datetime :responded_at

      t.timestamps
    end

    add_index :event_invitations, :event_role_id
    add_index :event_invitations, :staff_member_id
    add_index :event_invitations, [ :event_role_id, :staff_member_id ], unique: true
    add_foreign_key :event_invitations, :event_roles
    add_foreign_key :event_invitations, :staff_members
  end
end
