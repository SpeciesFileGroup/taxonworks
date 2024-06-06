require 'settings'
TaxonWorks::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  config.file_watcher = ActiveSupport::FileUpdateChecker

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = true

  # Show full error reports and disable caching.
  config.consider_all_requests_local = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # Limit log size to 512 MB total
  config.logger = ActiveSupport::Logger.new(config.paths['log'].first, 1, 256 * 1024 ** 2)

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations
  config.active_record.migration_error = :page_load

  # http://guides.rubyonrails.org/v5.1/configuring.html#configuring-assets
  # Assets

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = false # false # true if you are stuck
  #config.assets.quiet = false # is true by default
  config.assets.raise_runtime_errors = true

  # Needed to make shakapacker not use yarn
  config.shakapacker.check_yarn_integrity = false

  config.action_mailer.default_url_options = { host: 'localhost:3000' }

  # Load local settings
  Settings.load_from_settings_file(config, :development)

  BetterErrors.editor='x-mine://open?file=%{file}&line=%{line}' if defined? BetterErrors

  # Removed with zeitwerk
  # config.autoload_paths << Rails.root.join('lib/vendor/')
  # config.eager_load_paths << Rails.root.join('lib/vendor/')
  # require 'taxonworks'
  # require 'taxonworks/taxonworks_autoload'
end
