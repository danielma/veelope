class AddBankConnectionIdToBankAccounts < ActiveRecord::Migration[5.0]
  def change
    add_reference(:bank_accounts, :bank_connection, foreign_key: true, null: false)
  end
end
