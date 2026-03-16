class CreateAgencyStaffingCandidates < ActiveRecord::Migration[8.1]
  def change
    create_table :agency_staffing_candidates do |t|
      t.references :agency_staffing_request, null: false, foreign_key: true
      t.references :agency_staff_member, null: false, foreign_key: true
      t.integer  :status, null: false, default: 0
      t.datetime :accepted_at
      t.datetime :rejected_at
      t.text     :rejection_reason

      t.timestamps
    end
    add_index :agency_staffing_candidates, [ :agency_staffing_request_id, :agency_staff_member_id ], unique: true
  end
end
