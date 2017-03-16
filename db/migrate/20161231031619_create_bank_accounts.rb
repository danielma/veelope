class CreateBankAccounts < ActiveRecord::Migration[5.0]
  def change
    create_table :bank_accounts do |t|
      t.references :account, foreign_key: true, null: false
      t.string :name, null: false
      t.string :remote_identifier, null: false

      t.timestamps
    end
  end
end
