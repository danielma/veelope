class AddInstitutionNameToBankConnections < ActiveRecord::Migration[5.0]
  def change
    add_column :bank_connections, :institution_name, :string
  end
end
