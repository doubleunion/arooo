Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github, ENV['GITHUB_CLIENT_KEY'], ENV['GITHUB_CLIENT_SECRET']
end
