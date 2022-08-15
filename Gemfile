source "https://rubygems.org"

ruby "2.7.1"

gem "rails", "~>6.0"
gem "jquery-rails", ">= 4.3.5"
gem "turbolinks"
gem "jbuilder"
gem "figaro"
gem "omniauth"
gem "omniauth-github"
gem "omniauth-google-oauth2"
gem "pg"
gem "state_machine_deuxito", require: 'state_machine'
gem "protected_attributes_continued" # works w rails 5
gem "kaminari", ">= 1.2.1"
gem "rails_autolink", ">= 1.1.6"
gem "redcarpet"
gem "configurable_engine" , "~> 2"
gem "bugsnag"
gem "stripe", "~> 7" # TODO upgrade this! Carefully...
gem "stripe_event"
gem "rack-canonical-host"
gem "aws-sdk-rails", "~> 3"
gem "rack-cors"
gem "haml-rails", ">= 1.0.0"
gem "sass-rails", ">= 5.0.7"
gem "uglifier"
gem "coffee-rails", ">= 4.2.2"
gem "bootstrap-sass"
gem "jquery-datatables-rails", ">= 3.4.0"
gem "redis" # Used to store recently-authorized doorbell member

# Avoid low-severity security issue: https://github.com/advisories/GHSA-vr8q-g5c7-m54m
gem "nokogiri", ">= 1.11.0.rc4"

group :development do
  gem "annotate" # Show db schema as comments in models
  gem "better_errors" # Provides a better error page for Rails and other Rack apps
  gem "binding_of_caller" # Retrieve the binding of a method's caller
  gem "html2haml"
  gem "awesome_print"
end

group :development, :test do
  gem "rspec-rails", ">= 4.0.0"
  gem "faker"
  gem "rack_session_access"
  gem "pry-rails"
  gem "pry"
  gem "puma", "~> 5.6"
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
  gem "factory_bot_rails", ">= 6.1.0"
  gem "launchy"
  gem "rspec-collection_matchers"
  gem "selenium-webdriver"
  gem "shoulda-matchers"
  gem "stripe-ruby-mock", require: "stripe_mock"
  gem "simplecov"
  gem "rails-controller-testing", ">= 1.0.5"
end

gem "brakeman"
