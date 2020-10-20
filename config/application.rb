require File.expand_path("../boot", __FILE__)

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Doubleunion
  class Application < Rails::Application
    config.load_defaults 6.0
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # explicitly loading locales so they will be available in the initializers
    I18n.load_path += Dir[Rails.root.join("config", "locales", "**", "*.{rb,yml}")]

    config.eager_load_paths += %W[#{config.root}/lib]
    config.autoload_paths += %W[#{config.root}/lib]

    # CORS – this allows doubleunion.org to request the api from javascript
    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins "*"

        resource "/public_members", headers: :any, methods: [:get], max_age: 0
      end
    end
  end
end
