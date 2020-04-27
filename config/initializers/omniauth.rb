Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github, ENV["GITHUB_CLIENT_KEY"], ENV["GITHUB_CLIENT_SECRET"], origin_param: "return_to"
  provider :google_oauth2, ENV["GOOGLE_CLIENT_ID"], ENV["GOOGLE_CLIENT_SECRET"], origin_param: "return_to"
end
