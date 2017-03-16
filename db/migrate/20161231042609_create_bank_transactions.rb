class CreateBankTransactions < ActiveRecord::Migration[5.0]
  def change
    create_table :bank_transactions do |t|
      t.references :bank_account, foreign_key: true, null: false
      t.references :account, foreign_key: true, null: false
      t.string :payee, null: false
      t.datetime :posted_at, null: false
      t.monetize :amount
      t.string :memo

      t.timestamps
    end
  end
end
