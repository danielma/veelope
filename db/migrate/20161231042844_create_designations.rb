class CreateDesignations < ActiveRecord::Migration[5.0]
  def change
    create_table :designations do |t|
      t.references :account, foreign_key: true, null: false
      t.references :bank_transaction, foreign_key: true, null: false
      t.references :envelope, foreign_key: true, null: false
      t.monetize :amount

      t.timestamps
    end
  end
end
