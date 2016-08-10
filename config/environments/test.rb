TaxonWorks::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # The test environment is used exclusively to run your application's
  # test suite. You never need to work with it otherwise. Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs. Don't rely on the data there!
  config.cache_classes                              = false # true

  # Do not eager load code on boot. This avoids loading your whole application
  # just for the purpose of running a single test. If you are using a tool that
  # preloads Rails for running tests, you may have to set it to true.
  config.eager_load                                 = false

  # Configure static asset server for tests with Cache-Control for performance.
  config.serve_static_files                         = true 
  config.static_cache_control                       = "public, max-age=3600"

  # Show full error reports and disable caching.
  config.consider_all_requests_local                = true
  config.action_controller.perform_caching          = false

  # Raise exceptions instead of rendering exception templates.
  config.action_dispatch.show_exceptions            = false

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method              = :test

  # Print deprecation notices to the stderr.
  config.active_support.deprecation                 = :stderr

  config.action_mailer.default_url_options = { :host => "www.example.com" }

  Paperclip::Attachment.default_options[:path] = "#{Rails.root}/spec/test_files/:class/:id_partition/:style.:extension"

  # http://stackoverflow.com/questions/20183877/assets-are-not-loaded-during-capybara-rspec-spec
  # unless ENV['TAXONWORKS_TEST_WITH_PRECOMPILE']
  #   config.assets.prefix = '/assets_test'
  # end

  require 'taxonworks'
  require 'taxonworks_autoload'
end
