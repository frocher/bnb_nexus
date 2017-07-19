source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'rails', '~> 5.1.2'

# Database access
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
gem 'devise_token_auth', '>= 0.1.42'
gem 'omniauth-github'
gem 'omniauth-facebook'
gem 'omniauth-google-oauth2'
gem 'six'

# Configuration
gem 'figaro'

# Cron jobs
gem 'rufus-scheduler'

# launch
gem 'foreman'

# Use Puma as the app server
gem 'puma', '~> 3.7'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'

  gem 'annotate'
end

gem 'tzinfo-data'
