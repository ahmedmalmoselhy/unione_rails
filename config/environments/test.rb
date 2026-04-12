require 'active_support/core_ext/integer/time'

Rails.application.configure do
  config.cache_classes = true
  config.eager_load = ENV['CI'].present?
  config.consider_all_requests_local = true
  config.public_file_server.enabled = true
  config.public_file_server.headers = { 'Cache-Control' => "public, max-age=#{1.hour.to_i}" }
  config.active_support.deprecation = :stderr
  config.active_support.disallowed_deprecation = :raise
  config.active_support.disallowed_deprecation_warnings = []

  # Allow all hosts in test environment
  config.hosts = []

  # Mailer
  config.action_mailer.delivery_method = :test
  config.action_mailer.default_url_options = { host: 'localhost' }
end
