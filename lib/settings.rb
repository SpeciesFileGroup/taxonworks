module Settings

  EXCEPTION_NOTIFICATION_SETTINGS = [
    :email_prefix,
    :sender_address,
    :exception_recipients 
  ]

  VALID_SECTIONS = [
    :default_data_directory,
    :exception_notification
  ]

  @@default_data_directory = nil
  
  def self.load_from_hash(config, hash)
    invalid_sections = hash.keys - VALID_SECTIONS
    raise "#{invalid_sections} are not valid sections" unless invalid_sections.empty?

    load_exception_notification(config, hash[:exception_notification])
    load_default_data_directory(hash[:default_data_directory])
  end
  
  def self.load_from_file(config, path, set_name)
    hash = YAML.load_file(path)
    raise "#{set_name} settings set not found" unless hash.keys.include?(set_name.to_s)
    self.load_from_hash(config, symbolize_keys(hash[set_name.to_s] || { }))
  end
  
  def self.default_data_directory
    @@default_data_directory
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

end