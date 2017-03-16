class AddSourceToBankTransactions < ActiveRecord::Migration[5.0]
  def change
    add_column :bank_transactions, :source, :integer, default: 0, null: false
  end
end
