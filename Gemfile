source 'https://rubygems.org'

ruby '2.5.7'

gem 'rails', '>= 5.2.4.2'
gem 'jquery-rails', '>= 4.3.5'
gem 'turbolinks'
gem 'jbuilder'
gem 'figaro'
gem 'omniauth'
gem 'omniauth-github'
gem 'omniauth-google-oauth2'
gem 'pg', '0.21' # to move to v1, must upgrade activesupport
gem 'protected_attributes'
gem 'state_machine', git: "https://github.com/seuros/state_machine"
gem 'kaminari', '>= 1.1.1'
gem 'actionpack-action_caching', '>= 1.2.0'
gem 'rails_autolink', '>= 1.1.6'
gem 'redcarpet'
gem 'configurable_engine', '>= 0.5.0'
gem 'bugsnag'
gem 'stripe', '~> 3' # TODO upgrade this! Carefully...
gem 'stripe_event'
gem 'rack-canonical-host'
gem 'aws-sdk-rails', '>= 2.1.0'
gem 'rack-cors', '>= 1.0.5'

gem 'haml-rails', '>= 1.0.0'
gem 'sass-rails', '>= 5.0.7'
gem 'uglifier'
gem 'coffee-rails', '>= 4.2.2'
gem 'bootstrap-sass'
gem 'jquery-datatables-rails', '>= 3.4.0'

group :development do
  gem 'annotate' # Show db schema as comments in models
  gem 'better_errors' # Provides a better error page for Rails and other Rack apps
  gem 'binding_of_caller' # Retrieve the binding of a method's caller
  gem 'html2haml', '>= 2.2.0'
  gem 'quiet_assets' , '>= 1.1.0' # turns off Rails asset pipeline log
  gem 'awesome_print'
  gem 'execjs' # last updated 2016
  gem 'therubyracer' # Call JavaScript code and manipulate JavaScript objects from Ruby
end

group :development, :test do
  gem 'rspec-rails', '>= 3.8.2'
  gem 'thin'
  gem 'faker'
  gem 'rack_session_access'
  gem 'pry-rails'
  gem 'pry'
  gem 'puma' , '>= 3.12.4' # for capybara
  gem 'timecop'
end

group :production do
  gem 'unicorn'
  gem 'rails_12factor'
end

group :test do
  gem 'capybara', '>= 3.24.0'
  gem 'chromedriver-helper', '>= 2.1.1'
  gem 'database_cleaner'
  gem 'email_spec'
  gem 'factory_bot_rails', '~> 4', '>= 4.11.1'
  gem 'launchy'
  gem 'rspec-collection_matchers'
  gem 'selenium-webdriver'
  gem 'shoulda-matchers'
  gem 'stripe-ruby-mock', :require => 'stripe_mock'
end
