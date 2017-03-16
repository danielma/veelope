class AddRefreshedAtToBankConnections < ActiveRecord::Migration[5.0]
  def change
    add_column :bank_connections, :refreshed_at, :datetime
  end
end
