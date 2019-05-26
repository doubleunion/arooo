source 'https://rubygems.org'

ruby '2.4.6'

gem 'rails', '~> 4.2'
gem 'jquery-rails'
gem 'turbolinks'
gem 'jbuilder'
gem 'figaro'
gem 'omniauth'
gem 'omniauth-github'
gem 'omniauth-google-oauth2'
gem 'pg', '0.21' # to move to v1, must upgrade activesupport
gem 'protected_attributes'
gem 'state_machine', git: "https://github.com/seuros/state_machine"
gem 'kaminari'
gem 'actionpack-action_caching'
gem 'rails_autolink'
gem 'redcarpet'
gem 'configurable_engine'
gem 'bugsnag'
gem 'stripe', '2.5.0' # TODO upgrade this! Carefully...
gem 'stripe_event'
gem 'rack-canonical-host'
gem 'aws-sdk-rails', '~> 1.0'
gem 'rack-cors'

gem 'haml-rails'
gem 'sass-rails', '~> 4.0'
gem 'uglifier'
gem 'coffee-rails'
gem 'bootstrap-sass'
gem 'jquery-datatables-rails', '1.12.2' #TODO: upgrade this to the present

group :development do
  gem 'better_errors' # Provides a better error page for Rails and other Rack apps
  gem 'binding_of_caller' # Retrieve the binding of a method's caller
  gem 'html2haml'
  gem 'quiet_assets' # turns off Rails asset pipeline log
  gem 'awesome_print'
  gem 'execjs' # last updated 2016
  gem 'therubyracer' # Call JavaScript code and manipulate JavaScript objects from Ruby
end

group :development, :test do
  gem 'rspec-rails', '~> 3.4'
  gem 'thin'
  gem 'faker'
  gem 'rack_session_access'
  gem 'pry-rails'
  gem 'pry'
  gem 'puma' # for capybara
  gem 'timecop'
end

group :production do
  gem 'unicorn'
  gem 'rails_12factor'
end

group :test do
  gem 'capybara'
  gem 'chromedriver-helper'
  gem 'database_cleaner', '1.0.1'
  gem 'email_spec'
  gem 'factory_girl_rails'
  gem 'launchy'
  gem 'machinist'
  gem 'rspec-collection_matchers'
  gem 'selenium-webdriver'
  gem 'shoulda-matchers'
  gem 'stripe-ruby-mock', :require => 'stripe_mock'
end
