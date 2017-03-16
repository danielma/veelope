Plaid.config do |p|
  p.client_id = AppConfig.plaid.client_id
  p.secret = AppConfig.plaid.secret
  p.env = :tartan
end
