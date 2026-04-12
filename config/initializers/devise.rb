require 'devise'

# Devise setup for API-only mode
Devise.setup do |config|
  config.mailer_sender = 'noreply@unione.com'
  require 'devise/orm/active_record'
  config.skip_session_storage = true
  config.http_authenticatable = false
end
