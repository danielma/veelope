class AddSuccessfullyRefreshedAtToBankConnections < ActiveRecord::Migration[5.0]
  def change
    add_column :bank_connections, :successfully_refreshed_at, :datetime
  end
end
