class CreateEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :events do |t|
      t.string :event_name
      t.integer :event_type
      t.date :event_date
      t.string :venue
      t.string :reference_number
      t.time :setup_time
      t.time :event_start_time
      t.time :event_end_time
      t.time :teardown_time
      t.text :description
      t.integer :status, null: false, default: 0
      t.integer :wizard_step, null: false, default: 1
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
