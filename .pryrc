if defined?(Rails)
  ActsAsTenant.current_tenant = Account.first
end
