module Plaid
  class << self
    attr_accessor :client
  end

  self.client = Client.new(
    env: AppConfig.plaid.env.to_sym,
    client_id: AppConfig.plaid.client_id,
    secret: AppConfig.plaid.secret,
    public_key: AppConfig.plaid.public_key,
  )
end
