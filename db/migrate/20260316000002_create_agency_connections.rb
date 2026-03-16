class CreateAgencyConnections < ActiveRecord::Migration[8.0]
  def change
    create_table :agency_connections do |t|
      t.references :agency,       null: false, foreign_key: true
      t.integer    :status,       null: false, default: 0
      t.datetime   :confirmed_at
      t.references :confirmed_by, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :agency_connections, :agency_id, unique: true, name: "index_agency_connections_on_agency_id_unique"
  end
end
