module Settings

  EXCEPTION_NOTIFICATION_SETTINGS = [
    :email_prefix,
    :sender_address,
    :exception_recipients 
  ]

  VALID_SECTIONS = [
    :default_data_directory,
    :exception_notification,
    :action_mailer_smtp_settings,
    :action_mailer_url_host,
    :mail_domain,
    :capistrano
  ]

  @@default_data_directory = nil
  @@mail_domain = nil
  @@config_hash = nil 

  def self.load_from_hash(config, hash)
    invalid_sections = hash.keys - VALID_SECTIONS
    raise "#{invalid_sections} are not valid sections" unless invalid_sections.empty?

    @@config_hash = hash.deep_dup

    load_exception_notification(config, hash[:exception_notification])
    load_default_data_directory(hash[:default_data_directory])
    load_action_mailer_smtp_settings(config, hash[:action_mailer_smtp_settings])
    load_action_mailer_url_host(config, hash[:action_mailer_url_host])
    load_mail_domain(config, hash[:mail_domain])
  end
  
  def self.get_config_hash
    @@config_hash
  end
  
  def self.load_from_file(config, path, set_name)
    hash = YAML.load_file(path)
    raise "#{set_name} settings set not found" unless hash.keys.include?(set_name.to_s)
    self.load_from_hash(config, symbolize_keys(hash[set_name.to_s] || { }))
  end
  
  def self.default_data_directory
    @@default_data_directory
  end
  
  def self.mail_domain
    @@mail_domain
  end
  
  private
  def self.symbolize_keys(hash)
    hash.inject({}) do |h, (k, v)|
      h[k.is_a?(String) ? k.to_sym : k] = (v.is_a?(Hash) ? symbolize_keys(v) : v)
      h
    end
  end
  
  def self.load_default_data_directory(path)
    @@default_data_directory = nil
    if !path.nil?
      full_path = File.absolute_path(path)
      raise "Directory #{full_path} does not exist" unless Dir.exists?(full_path)
      @@default_data_directory = full_path
    end
  end
  
  def self.load_exception_notification(config, settings)
    if settings      
      missing = EXCEPTION_NOTIFICATION_SETTINGS - settings.keys
      raise "Missing #{missing} settings in exception_notification" unless missing.empty?
      
      invalid = settings.keys - EXCEPTION_NOTIFICATION_SETTINGS
      raise "#{invalid} are not valid settings for exception_notification" unless invalid.empty?
      
      raise ":exception_recipients must be an Array" unless settings[:exception_recipients].class == Array

      config.middleware.use ExceptionNotification::Rack, email: settings
    end    
  end
  
  def self.load_action_mailer_smtp_settings(config, settings)
    if settings
      config.action_mailer.delivery_method = :smtp
      config.action_mailer.smtp_settings = settings
    end
  end
  
  def self.load_action_mailer_url_host(config, url_host)
    if url_host
      config.action_mailer.default_url_options = { :host => url_host }
    end
  end
  
  def self.load_mail_domain(config, mail_domain)
    @@mail_domain = mail_domain
  end

end
