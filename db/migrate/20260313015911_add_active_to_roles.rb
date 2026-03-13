class AddActiveToRoles < ActiveRecord::Migration[8.1]
  def change
    add_column :roles, :active, :boolean, default: true, null: false
  end
end
