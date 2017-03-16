require_relative 'boot'

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
# require "action_mailer/railtie"
require "action_view/railtie"
# require "action_cable/engine"
require "sprockets/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Veelope
  class Application < Rails::Application
    config.sass.preferred_syntax = :sass

    ::AppConfig = ConfigSpartan.create do
      file "#{Rails.root}/config/application.yml"
      file "#{Rails.root}/config/environments/#{Rails.env}.yml"
      file "#{Rails.root}/config/environments/#{Rails.env}_secrets.yml"
    end

    config.secret_key_base = AppConfig.secret_key_base

    config.autoload_paths += [
      Rails.root.join("app/services/concerns"),
    ]

    config.active_job.queue_adapter = :sidekiq

    config.react.camelize_props = true
  end
end
