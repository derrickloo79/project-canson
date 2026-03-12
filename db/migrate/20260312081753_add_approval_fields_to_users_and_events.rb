class AddApprovalFieldsToUsersAndEvents < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :approving_manager_id, :integer
    add_foreign_key :users, :users, column: :approving_manager_id

    add_column :events, :rejection_reason, :text
  end
end
