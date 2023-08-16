require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
# Bundler.require(:default, Rails.env)

Bundler.require *Rails.groups


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
    # config.autoload_paths += %W(#{config.root}/lib) # #{config.root}/extras

    # TODO: clean module/class names so that this works:
    # config.autoload_paths += Dir[ Rails.root.join('lib', '**/') ]

    # Fix deprecation warning by adopting future Rails 6.1 behaviour
    config.action_dispatch.return_only_media_type_on_content_type = false

    config.autoload_paths << "#{Rails.root.join("lib")}"
    config.autoload_paths << "#{Rails.root.join("lib/vendor")}"

    #Include separate assets
    config.assets.precompile += %w( separated_application.js )

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

    # Raise error on `after_rollback`/`after_commit` callbacks
    # deprecated, no replacement R5.0
    # config.active_record.raise_in_transactional_callbacks = true

    config.active_job.queue_adapter = :delayed_job

    # config.logger = Logger.new(STDOUT)
    # config.logger = Log4r::Logger.new('Application Log')

    config.autoloader = :classic
  end
end
