class AddTypeToBankAccounts < ActiveRecord::Migration[5.0]
  def change
    add_column :bank_accounts, :type, :integer, null: false
  end
end
