source 'https://rubygems.org'

ruby '>= 3.1.0'

gem 'rails', '~> 7.1'
gem 'puma', '>= 5.0'
gem 'pg', '~> 1.5'
gem 'bootsnap', require: false

# Authentication & Authorization
gem 'devise', '~> 4.9'
gem 'jwt', '~> 2.7'
gem 'pundit', '~> 2.3'

# Security
gem 'rack-attack', '~> 6.7'
gem 'rack-cors', '~> 2.0'

# Excel import/export
gem 'caxlsx', '~> 4.1'
gem 'caxlsx_rails', '~> 0.6'
gem 'roo', '~> 2.10'

# PDF & iCal
gem 'wicked_pdf', '~> 2.7'
gem 'wkhtmltopdf-binary', '~> 0.12.6'
gem 'icalendar', '~> 2.10'
gem 'prawn', '~> 2.4'
gem 'prawn-table', '~> 0.2.2'

# Background jobs
gem 'sidekiq', '~> 7.0'
gem 'redis', '~> 5.0'

# Pagination
gem 'kaminari', '~> 1.2'

# API JSON serialization
gem 'jbuilder', '~> 2.11'

group :development, :test do
  gem 'rspec-rails', '~> 6.1'
  gem 'factory_bot_rails', '~> 6.4'
  gem 'faker', '~> 3.2'
  gem 'database_cleaner-active_record', '~> 2.1'
  gem 'shoulda-matchers', '~> 6.0'
  gem 'debug', platforms: %i[mri windows]
end

group :development do
  gem 'letter_opener', '~> 1.8'
  gem 'annotate', '~> 3.2'
  gem 'better_errors', '~> 2.10'
  gem 'binding_of_caller', '~> 1.0'
end

group :test do
  gem 'simplecov', require: false
  gem 'capybara', '~> 3.39'
  gem 'selenium-webdriver', '~> 4.15'
end
