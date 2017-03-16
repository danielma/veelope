class AddTimezoneToAccounts < ActiveRecord::Migration[5.0]
  def change
    add_column :accounts, :time_zone, :string
  end
end
