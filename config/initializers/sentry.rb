Sentry.init do |config|
  config.dsn = ENV['SENTRY_DSN']
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]
  config.environment = ENV.fetch('SENTRY_ENVIRONMENT', Rails.env)
  config.traces_sample_rate = ENV.fetch('SENTRY_TRACES_SAMPLE_RATE', '0.0').to_f
  
  # Filter out common sensitive fields
  config.send_default_pii = false
end if defined?(Sentry) && ENV['SENTRY_DSN'].present?
