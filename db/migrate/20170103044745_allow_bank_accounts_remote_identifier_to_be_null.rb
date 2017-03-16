class AllowBankAccountsRemoteIdentifierToBeNull < ActiveRecord::Migration[5.0]
  def change
    change_column_null :bank_accounts, :remote_identifier, true
    change_column_null :bank_accounts, :bank_connection_id, true
  end
end
