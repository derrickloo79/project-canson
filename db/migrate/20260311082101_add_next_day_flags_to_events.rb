class AddNextDayFlagsToEvents < ActiveRecord::Migration[8.1]
  def change
    add_column :events, :end_time_next_day, :boolean, default: false, null: false
    add_column :events, :teardown_next_day, :boolean, default: false, null: false
  end
end
