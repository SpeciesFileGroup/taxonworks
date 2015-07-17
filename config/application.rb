require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module TaxonWorks
  class Application < Rails::Application
    # Via https://github.com/matthuhiggins/foreigner/pull/95
    #  config.before_initialize do
    #    Foreigner::Adapter.register 'postgis', 'foreigner/connection_adapters/postgresql_adapter'
    #  end

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Pre-load all libraries in /lib

    config.autoload_paths += %W(#{config.root}/lib) # #{config.root}/extras

    # Breaks rake/loading becahse of existing Rails.application.eager_load! statements 
    # config.eager_load_paths += %W(#{config.root}/lib) # #{config.root}/extras

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # When using PostGIS adapter make sure schema dumps are in :ruby format not
    # :sql - because low level :sql will not be correct for spatial db
    # @see http://dazuma.github.io/activerecord-postgis-adapter/rdoc/Documentation_rdoc.html
    config.active_record.schema_format :ruby

    RGeo::ActiveRecord::SpatialFactoryStore.instance.tap do |config|
      # By default, use the GEOS implementation for spatial columns.
      config.default = RGeo::Geos.factory_generator
    end

  end
end
