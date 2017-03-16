class AddUniqueKeyToBankTransactionsRemoteIdentifier < ActiveRecord::Migration[5.0]
  def change
    add_index :bank_transactions, :remote_identifier, unique: true
  end
end
