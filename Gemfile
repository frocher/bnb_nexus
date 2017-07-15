source 'https://rubygems.org'

gem 'rails', '4.2.7.1'
gem 'rake', '~> 11.2.2'

gem 'rails-api'
gem 'jbuilder'

# Databse access
gem 'sqlite3'
gem 'mysql2'
gem 'influxer'

# Validation
gem 'validate_url'

# Pagination
gem 'kaminari'

# Files attachments
gem 'paperclip'

# Notifications (mail, slack)
gem 'sparkpost'
gem 'slack-notifier'
gem 'slim'

# Time manipulation
gem 'chronic_duration'

# Auth
gem 'devise_token_auth', '>= 0.1.32.beta9'
gem 'omniauth-github'
gem 'omniauth-facebook'
gem 'omniauth-google-oauth2'
gem 'six'

# Configuration
gem 'figaro'

# Cron jobs
gem 'sidekiq'
gem 'sidekiq-limit_fetch'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  gem 'annotate'

  # for sidekiq ui
  gem 'sinatra', :require => nil
end

# To use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use puma as the app server
gem 'foreman'
gem 'puma'

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'
