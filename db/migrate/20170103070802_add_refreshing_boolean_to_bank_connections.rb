class AddRefreshingBooleanToBankConnections < ActiveRecord::Migration[5.0]
  def change
    add_column :bank_connections, :refreshing, :boolean, default: false, null: false
  end
end
