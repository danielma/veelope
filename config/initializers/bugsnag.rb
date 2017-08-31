if AppConfig.bugsnag && AppConfig.bugsnag.api_key.present?
  Bugsnag.configure do |config|
    config.api_key = AppConfig.bugsnag.api_key
  end
end
