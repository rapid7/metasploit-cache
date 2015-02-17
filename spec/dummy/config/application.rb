require File.expand_path('../boot', __FILE__)

require 'rails/all'

Bundler.require(*Rails.groups(documentation: [:development]))

# require the engine being tested.  In a non-dummy app this would be handled by the engine's gem being in the Gemfile
# for real app and Bundler.require requiring the gem.
require 'metasploit/cache'
require 'metasploit/cache/engine'

if ENV['METASPLOIT_FRAMEWORK_ROOT']
  require 'metasploit/framework'
  require 'metasploit/framework/engine'
end

module Dummy
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    config.i18n.enforce_available_locales = true
  end
end

