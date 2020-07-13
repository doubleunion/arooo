# This file is copied to spec/ when you run 'rails generate rspec:install'
require "simplecov"
SimpleCov.start

ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../../config/environment", __FILE__)
require "rspec/rails"
require "email_spec"
require "capybara/rails"
require "rack_session_access/capybara"
require "shoulda/matchers"
require "stripe_mock"

Capybara.register_driver :selenium do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument("headless")
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].sort.each { |f| require f }

OmniAuth.config.test_mode = true

OmniAuth.config.add_mock(:github, {
  uid: "12345",
  extra: {raw_info: {login: "someone"}},
  info: {name: "Some One", email: "someone@foo.bar"}
})

OmniAuth.config.add_mock(:google_oauth2, {
  uid: "67890",
  info: {name: "Cool Cat", email: "basil@example.com"}
})

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

RSpec.configure do |config|
  config.include(EmailSpec::Helpers)
  config.include(EmailSpec::Matchers)
  config.include FactoryBot::Syntax::Methods

  config.infer_spec_type_from_file_location!

  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  # We use DatabaseCleaner. Using the built in transactional fixtures doesn't
  # work with feature specs, as creating a user and logging in are separate
  # threads.
  config.use_transactional_fixtures = false

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"

  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
  end
  config.before(:each) do
    DatabaseCleaner.start
  end
  config.after(:each) do
    DatabaseCleaner.clean
  end
end

module AuthHelper
  def login_as(user_or_state, attrs = {})
    user = user_or_state.is_a?(User) ? user_or_state : nil
    user ||= create(:user, attrs.merge(state: user_or_state))
    allow(controller).to receive(:current_user).and_return(user)
    user
  end

  def log_in(user)
    allow(controller).to receive(:current_user).and_return(user)
  end
end
