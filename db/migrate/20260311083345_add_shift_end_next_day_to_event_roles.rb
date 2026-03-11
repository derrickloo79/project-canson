class AddShiftEndNextDayToEventRoles < ActiveRecord::Migration[8.1]
  def change
    add_column :event_roles, :shift_end_next_day, :boolean, default: false, null: false
  end
end
