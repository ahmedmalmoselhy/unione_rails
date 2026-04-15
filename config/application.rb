require_relative 'boot'

require 'rails'
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_view/railtie'
require 'active_storage/engine'
require 'action_text/engine'
require 'action_mailbox/engine'

# Require the gems listed in Gemfile
Bundler.require(*Rails.groups)

# Require middleware
require_relative '../app/middleware/audit_log_middleware'

module UniOne
  class Application < Rails::Application
    config.load_defaults 7.1

    # API-only mode
    config.api_only = true

    # Timezone
    config.time_zone = 'UTC'
    config.active_record.default_timezone = :utc

    # I18n
    config.i18n.default_locale = :en
    config.i18n.available_locales = [:en, :ar]

    # Generators
    config.generators do |g|
      g.test_framework :rspec, fixture: false
      g.fixture_replacement :factory_bot, dir: 'spec/factories'
    end

    # Active Job
    config.active_job.queue_adapter = :sidekiq

    # Middleware
    config.middleware.use AuditLogMiddleware
  end
end
