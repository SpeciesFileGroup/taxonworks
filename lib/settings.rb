# Server/application configuration settings

require 'utilities'
require 'utilities/hashes'
require 'taxonworks_net'
module Settings

  class Error < RuntimeError; end;

  EXCEPTION_NOTIFICATION_SETTINGS = [
    :email_prefix,
    :sender_address,
    :exception_recipients
  ].freeze

  VALID_SECTIONS = [
    :backup_directory,
    :default_data_directory,
    :exception_notification,
    :action_mailer_smtp_settings,
    :action_mailer_url_host,
    :mail_domain,
    :capistrano,
    :interface,
    :selenium
  ].freeze

  @@backup_directory = nil
  @@default_data_directory = nil
  @@mail_domain = nil
  @@config_hash = nil

  @@sandbox_mode = false
  @@sandbox_commit_sha = nil
  @@sandbox_short_commit_sha = nil
  @@sandbox_commit_date = nil

  @@selenium_settings = {}

  # @param [Hash] config
  # @param [Hash] hash
  # @return [Boolean]
  def self.load_from_hash(config, hash)
    invalid_sections = hash.keys - VALID_SECTIONS
    raise Error, "#{invalid_sections} are not valid sections" unless invalid_sections.empty?

    @@config_hash = hash.deep_dup

    load_exception_notification(config, hash[:exception_notification])
    load_default_data_directory(hash[:default_data_directory])
    load_backup_directory(hash[:backup_directory])
    load_action_mailer_smtp_settings(config, hash[:action_mailer_smtp_settings])
    load_action_mailer_url_host(config, hash[:action_mailer_url_host])
    load_mail_domain(config, hash[:mail_domain])
    load_interface(hash[:interface])
    load_selenium_config(hash[:selenium]) if hash[:selenium]
    true
  end

  # @return [Hash]
  def self.get_config_hash
    @@config_hash
  end

  # @param [Hash] config
  # @param [String] path
  # @param [Symbol] set_name
  def self.load_from_file(config, path, set_name)
    hash = YAML.load_file(path)
    if hash.keys.include?(set_name.to_s)
      self.load_from_hash(config, Utilities::Hashes.symbolize_keys(hash[set_name.to_s] || { }))
    else
      # require settings for production, but technically not test/development
      raise Error, "#{set_name} settings set not found" unless %w{production test development}.include?(set_name.to_s)
    end
  end

  # @param [Hash] config
  # @param [Symbol] set_name
  def self.load_from_settings_file(config, set_name)
    self.load_from_file(config, 'config/application_settings.yml', set_name) if File.exist?('config/application_settings.yml')
  end

  # @return [String]
  def self.default_data_directory
    @@default_data_directory
  end

  # @return [String]
  def self.backup_directory
    @@backup_directory
  end

  # @return [String]
  def self.mail_domain
    @@mail_domain
  end

  # @return [Boolean]
  def self.sandbox_mode?
    @@sandbox_mode
  end

  # @return [String]
  def self.sandbox_commit_sha
    @@sandbox_commit_sha
  end

  # @return [String]
  def self.sandbox_short_commit_sha
    @@sandbox_short_commit_sha
  end

  # @return [Date]
  def self.sandbox_commit_date
    @@sandbox_commit_date
  end

  # @return [Hash]
  def self.selenium_settings
    @@selenium_settings
  end

  # @param [String] path
  def self.setup_directory(path)
    if !Dir.exists?(path)
      # TODO: use/open a logger
      Rainbow("Directory #{path} does not exist, creating").purple
      FileUtils.mkdir_p(path)
      raise Error, "Directory #{path} could not be made, check permissions" unless Dir.exists?(path)
    end
  end

  # @param [String] path
  # @return [String]
  def self.load_default_data_directory(path)
    @@default_data_directory = nil
    if !path.nil?
      full_path = File.absolute_path(path)
      setup_directory(full_path)
      @@default_data_directory = full_path
    end
  end

  # @param [String] path
  # @return [String]
  def self.load_backup_directory(path)
    @@backup_directory = nil
    if !path.nil?
      full_path = File.absolute_path(path)
      setup_directory(full_path)
      @@backup_directory = full_path
    end
  end

  # @param [Hash] config
  # @param [Hash] settings
  def self.load_exception_notification(config, settings)
    if settings
      config.middleware.use ExceptionNotification::Rack, email: process_exception_notification(settings)
    end
  end

  # @param [Hash] settings
  # @return [Hash]
  def self.process_exception_notification(settings)
    missing = EXCEPTION_NOTIFICATION_SETTINGS - settings.keys
    raise Error, "Missing #{missing} settings in exception_notification" unless missing.empty?

    invalid = settings.keys - EXCEPTION_NOTIFICATION_SETTINGS
    raise Error, "#{invalid} are not valid settings for exception_notification" unless invalid.empty?

    settings[:exception_recipients] = settings[:exception_recipients].split(',') unless settings[:exception_recipients].class == Array || settings[:exception_recipients].blank?

    settings[:sections] = %w{github_link request session environment backtrace full_backtrace}

    raise Error, ':exception_recipients must be an Array' unless settings[:exception_recipients].class == Array

    settings
  end

  # @param [Hash] settings
  def self.load_interface(settings)
    if settings
      invalid = settings.keys - [:sandbox_mode]
      raise Error, "#{invalid} are not valid settings for interface" unless invalid.empty?
      if settings[:sandbox_mode] == true
        @@sandbox_mode = true
        @@sandbox_commit_sha = TaxonworksNet.commit_sha
        @@sandbox_short_commit_sha = TaxonworksNet.commit_sha.try(:slice!, 0, 12)
        @@sandbox_commit_date = TaxonworksNet.commit_date
      end
    end
  end

  # @param [Hash] settings
  # @return [Hash]
  def self.load_selenium_config(settings)
    invalid = settings.keys - [:browser, :marionette, :firefox_binary_path, :chromedriver_path, :headless]

    raise Error, "#{invalid} are not valid settings for test:selenium." unless invalid.empty?
    raise Error, "Can not find Firefox browser binary #{settings[:firefox_binary_path]}." if settings[:browser] == :firefox && !settings[:firefox_binary_path].blank? && !File.exists?(settings[:firefox_binary_path])
    raise Error, "Can not find chromedriver #{ settings[:chromedriver_path] }." if settings[:browser] == :chrome && !settings[:chromedriver_path].blank? && !File.exists?(settings[:chromedriver_path])

    settings.each do |k,v|
      @@selenium_settings[k] = v if !v.blank?
    end
  end

  # @param [Hash] config
  # @param [Hash] settings
  # @return [Hash]
  def self.load_action_mailer_smtp_settings(config, settings)
    if settings
      config.action_mailer.delivery_method = :smtp
      config.action_mailer.smtp_settings = {openssl_verify_mode: 'none'}.merge!(settings)
    end
  end

  # @param [Hash] config
  # @param [String] url_host
  # @return [Boolean]
  def self.load_action_mailer_url_host(config, url_host)
    if url_host
      config.action_mailer.default_url_options = { host: url_host }
    end
  end

  # @param [Hash] config
  # @param [String] mail_domain
  # @return [String]
  def self.load_mail_domain(config, mail_domain)
    @@mail_domain = mail_domain
  end

  # @param [Hash] config
  # @return [Boolean]
  def self.load_test_defaults(config)
    load_from_hash(config, {
      exception_notification: {
        email_prefix: '[TW-Error] ',
        sender_address: %{"notifier" <notifier@example.com>},
        exception_recipients: %w{exceptions@example.com},
      },
      mail_domain: 'example.com',
      selenium: {
        browser: 'firefox',
        marionette: false,
        firefox_binary_path: nil,
        chromedriver_path: nil
      }
    })
  end

end
