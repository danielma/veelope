class CreateEnvelopeGroups < ActiveRecord::Migration[5.0]
  def change
    create_table :envelope_groups do |t|
      t.references :account, foreign_key: true, null: false
      t.string :name, null: false

      t.timestamps
    end
  end
end
