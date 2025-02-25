require_relative 'boot'
require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
# Bundler.require(:default, Rails.env)

Bundler.require *Rails.groups

module TaxonWorks
  class Application < Rails::Application

    # TODO: remove on Sound implementation
    config.active_storage.service = false

    # Reverted from 7.2
    config.load_defaults 7.1

    # TODO: confirm 7.1 settings are meaningful
    config.active_record.belongs_to_required_by_default = false

    # TODO: remove after testing
    # With no settings set:
    #   config.action_controller.allow_deprecated_parameters_hash_equality = nil
    #   config.action_dispatch.debug_exception_log_level = :fatal # (not :error)
    #   config.action_text.sanitizer_vendor = nil
    #   config.active_job.use_big_decimal_serializer = nil
    #   config.active_record.allow_deprecated_singular_associations_name = nil
    #   config.active_record.before_committed_on_all_records = nil
    #   config.active_record.belongs_to_required_validates_foreign_key = false # false # !! false in 7.1
    #   config.active_record.commit_transaction_on_non_local_return = nil
    #   config.active_record.default_column_serializer = nil
    #   config.active_record.encryption.hash_digest_class = nil
    #   config.active_record.encryption.support_sha1_for_non_deterministic_encryption = nil
    #   config.active_record.generate_secure_token_on = :create # !! (is :initialize in 7.1)
    #   config.active_record.marshalling_format_version = nil
    #   config.active_record.query_log_tags_format = :legacy # !! (is :sqlcommenter in 7.1)
    #   config.active_record.raise_on_assign_to_attr_readonly = false # !! (is true in 7.1)
    #   config.active_record.run_after_transaction_callbacks_in_order_defined = nil # (true in 7.1)
    #   config.active_record.run_commit_callbacks_on_first_saved_instances_in_transaction = nil # (false in 7.1)
    #   config.active_record.sqlite3_adapter_strict_strings_by_default = nil
    #   config.active_support.cache_format_version = nil
    #   config.active_support.message_serializer = nil
    #   config.active_support.raise_on_invalid_cache_expiration_time = nil
    #   config.active_support.use_message_serializer_for_metadata = nil
    #   config.add_autoload_paths_to_load_path = true #  !! (this must be it, false in 7.1)
    #   config.dom_testing_default_html_version = :html4 # !! (Nokogiri/HTML 5 options here)
    #   config.precompile_filter_parameters = nil


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

    # Zietwerk currently requires both, review
    config.autoload_paths << "#{Rails.root.join("lib")}"

    #Include separate assets
    config.assets.precompile += %w( separated_application.js )

    # Breaks rake/loading because of existing Rails.application.eager_load! statements

    # zeitwerk not needed?
    config.eager_load_paths += config.autoload_paths     # Tentatively reverted from 7.2 update

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

    config.autoloader = :zeitwerk

    ["generators", "assets", "tasks"].each do |subdirectory|
      Rails.autoloaders.main.ignore("#{Rails.root}/lib/#{subdirectory}")
    end
  end
end
