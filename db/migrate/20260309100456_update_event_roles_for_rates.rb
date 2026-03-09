class UpdateEventRolesForRates < ActiveRecord::Migration[8.1]
  def change
    remove_column :event_roles, :dress_code, :string
    add_column    :event_roles, :rate, :decimal, precision: 10, scale: 2
  end
end
