source 'https://rubygems.org'

ruby '>= 3.1.0'

gem 'rails', '~> 7.1'
gem 'puma', '>= 5.0'
gem 'pg', '~> 1.5'
gem 'bootsnap', require: false

# Authentication & Authorization
gem 'devise'
gem 'jwt'
gem 'pundit'

# Security
gem 'rack-attack'
gem 'rack-cors'

# Excel import/export
gem 'roo'
gem 'axlsx'
gem 'axlsx_rails'

# PDF & iCal
gem 'wicked_pdf'
gem 'wkhtmltopdf-binary'
gem 'icalendar'

# Background jobs
gem 'sidekiq', '~> 7.0'
gem 'redis', '~> 5.0'

# Pagination
gem 'kaminari'

# API JSON serialization
gem 'jbuilder'

group :development, :test do
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'database_cleaner-active_record'
  gem 'shoulda-matchers'
  gem 'debug', platforms: %i[mri windows]
end

group :development do
  gem 'letter_opener'
  gem 'annotate'
  gem 'better_errors'
  gem 'binding_of_caller'
end

group :test do
  gem 'simplecov', require: false
  gem 'capybara'
  gem 'selenium-webdriver'
end
