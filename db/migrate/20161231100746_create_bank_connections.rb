class CreateBankConnections < ActiveRecord::Migration[5.0]
  def change
    create_table :bank_connections do |t|
      t.string :plaid_access_token, null: false
      t.references :account, foreign_key: true, null: false

      t.timestamps
    end
  end
end
