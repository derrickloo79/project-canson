class CreateAgencyStaffingRequests < ActiveRecord::Migration[8.1]
  def change
    create_table :agency_staffing_requests do |t|
      t.references :event_role, null: false, foreign_key: true
      t.references :agency, null: false, foreign_key: true
      t.references :requested_by, null: false, foreign_key: { to_table: :users }
      t.integer  :vacancies_requested, null: false
      t.text     :notes
      t.integer  :status, null: false, default: 0
      t.datetime :declined_at
      t.text     :declined_reason
      t.datetime :submitted_at

      t.timestamps
    end
    add_index :agency_staffing_requests, [ :event_role_id, :agency_id ], unique: true
  end
end
