class AddRemoteIdentifierToBankTransactions < ActiveRecord::Migration[5.0]
  def change
    add_column :bank_transactions, :remote_identifier, :string
  end
end
