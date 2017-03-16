class CreateEnvelopes < ActiveRecord::Migration[5.0]
  def change
    create_table :envelopes do |t|
      t.references :account, foreign_key: true, null: false
      t.references :envelope_group, foreign_key: true, null: false
      t.string :name, null: false

      t.timestamps
    end
  end
end
