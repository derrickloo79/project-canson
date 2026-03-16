class CreateAgencies < ActiveRecord::Migration[8.0]
  def change
    create_table :agencies do |t|
      t.string   :name,                    null: false
      t.string   :contact_email,           null: false
      t.string   :phone
      t.string   :website
      t.string   :invitation_token,        null: false
      t.datetime :invitation_sent_at
      t.datetime :invitation_accepted_at
      t.references :invited_by, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :agencies, :invitation_token, unique: true
    add_index :agencies, :contact_email,    unique: true
  end
end
