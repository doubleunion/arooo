Bugsnag.configure do |config|
  config.api_key = ENV["BUGSNAG_KEY"]
  config.notify_release_stages = ["staging", "production"]
end
