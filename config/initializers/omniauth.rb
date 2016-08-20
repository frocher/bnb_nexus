::OmniAuthConfig = Proc.new do
  provider :github,        ENV['GITHUB_KEY'],   ENV['GITHUB_SECRET'],   scope: 'email,profile'
  provider :facebook,      ENV['FACEBOOK_KEY'], ENV['FACEBOOK_SECRET']
  provider :google_oauth2, ENV['GOOGLE_KEY'],   ENV['GOOGLE_SECRET']
end

OmniAuth.config.on_failure = Proc.new do |env|
  Users::OmniauthCallbacksController.action(:omniauth_failure).call(env)
end
