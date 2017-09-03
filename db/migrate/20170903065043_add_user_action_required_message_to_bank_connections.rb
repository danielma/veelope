class AddUserActionRequiredMessageToBankConnections < ActiveRecord::Migration[5.0]
  def change
    add_column :bank_connections, :user_action_required_message, :text
  end
end
