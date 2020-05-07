source "https://rubygems.org"

ruby "2.7.1"

gem "rails", "~>5.0"
gem "rails"
gem "jquery-rails"
gem "turbolinks"
gem "jbuilder"
gem "figaro"
gem "omniauth"
gem "omniauth-github"
gem "omniauth-google-oauth2"
gem "pg", "0.21" # to move to v1, must upgrade activesupport
gem "state_machine_deuxito", require: 'state_machine'
gem "protected_attributes_continued" # works w rails 5
gem "kaminari"
gem "actionpack-action_caching"
gem "rails_autolink"
gem "redcarpet"
# gem "configurable_engine"
gem "bugsnag"
gem "stripe", "~> 3" # TODO upgrade this! Carefully...
gem "stripe_event"
gem "rack-canonical-host"
gem "aws-sdk-rails"
gem "rack-cors"
gem "haml-rails"
gem "sass-rails"
gem "uglifier"
gem "coffee-rails"
gem "bootstrap-sass"
gem "jquery-datatables-rails"
gem "bigdecimal", "1.4.4" # specify this directly to get around the error NoMethodError: undefined method `new' for BigDecimal:Class

group :development do
  gem "annotate" # Show db schema as comments in models
  gem "better_errors" # Provides a better error page for Rails and other Rack apps
  gem "binding_of_caller" # Retrieve the binding of a method's caller
  gem "html2haml"
  # gem "quiet_assets" # turns off Rails asset pipeline log; disabled because of Rails 5 upgrade shenanigans
  gem "awesome_print"
  gem "execjs" # last updated 2016
  gem "therubyracer" # Call JavaScript code and manipulate JavaScript objects from Ruby
  # gem 'rails_upgrader'
end

group :development, :test do
  gem "rspec-rails"
  gem "thin"
  gem "faker"
  gem "rack_session_access"
  gem "pry-rails"
  gem "pry"
  gem "puma"
  gem "standard"
  gem "timecop"
end

group :production do
  gem "unicorn"
  gem "rails_12factor"
end

group :test do
  gem "capybara"
  gem "webdrivers"
  gem "database_cleaner"
  gem "email_spec"
  gem "factory_bot_rails"
  gem "launchy"
  gem "rspec-collection_matchers"
  gem "selenium-webdriver"
  gem "shoulda-matchers"
  gem "stripe-ruby-mock", require: "stripe_mock"
  gem "simplecov"
  gem 'rails-controller-testing'
end
