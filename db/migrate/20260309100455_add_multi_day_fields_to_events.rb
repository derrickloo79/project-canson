class AddMultiDayFieldsToEvents < ActiveRecord::Migration[8.1]
  def change
    add_column :events, :multi_day, :boolean, null: false, default: false
    add_column :events, :event_end_date, :date
  end
end
