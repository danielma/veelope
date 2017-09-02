namespace :plaid do
  desc "upgrade access tokens"
  task upgrade_access_tokens: :environment do
    BankConnection.transaction do
      BankConnection.unscoped.each do |connection|
        ActsAsTenant.with_tenant(connection.account) do
          begin
            puts "Upgrading ##{connection.id}"
            new_token_response = Plaid.client.item.access_token.update_version(connection.plaid_access_token)
            new_token = new_token_response["access_token"]

            connection.update!(plaid_access_token: new_token)
          rescue Plaid::InvalidRequestError => e
            puts "Could not upgrade ##{connection.id}"
            Bugsnag.notify(e)
          end
        end
      end
    end
  end
end
