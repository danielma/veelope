class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.references :account, foreign_key: true, null: false
      t.string :username, null: false
      t.string :password_digest, null: false
      t.string :auth_token, null: false

      t.index :username, unique: true
      
      t.timestamps
    end
  end
end
