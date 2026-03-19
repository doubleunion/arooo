ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../../Gemfile", __FILE__)

require "bundler/setup" # Set up gems listed in the Gemfile.
require "logger" # Must be loaded before ActiveSupport on Ruby 3.1+
