Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github, ENV['OMNIAUTH_PROVIDER_KEY'], ENV['OMNIAUTH_PROVIDER_SECRET']
end
