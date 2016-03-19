# Use this hook to configure devise mailer, warden hooks and so forth.
# Many of these configuration options can be set straight in your model.
Devise.setup do |config|
  config.mailer_sender = 'jeeves.thebot@botnbot.com'
  config.secret_key = Figaro.env.devise_secret_key if Rails.env.production?
end
