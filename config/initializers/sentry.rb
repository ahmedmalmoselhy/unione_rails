begin
  require 'sentry-ruby'
rescue LoadError
  nil
end

if defined?(Sentry) && ENV['SENTRY_DSN'].present?
  Sentry.init do |config|
    config.dsn = ENV['SENTRY_DSN']
    config.environment = ENV.fetch('SENTRY_ENVIRONMENT', Rails.env)
    config.traces_sample_rate = ENV.fetch('SENTRY_TRACES_SAMPLE_RATE', '0.0').to_f
    config.send_default_pii = false
  end
end
