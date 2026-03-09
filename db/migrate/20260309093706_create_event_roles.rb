class CreateEventRoles < ActiveRecord::Migration[8.1]
  def change
    create_table :event_roles do |t|
      t.references :event, null: false, foreign_key: true
      t.string :role_name
      t.integer :vacancies
      t.time :shift_start
      t.time :shift_end
      t.string :dress_code
      t.text :requirements
      t.integer :position

      t.timestamps
    end
  end
end
