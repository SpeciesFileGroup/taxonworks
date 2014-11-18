module Settings
  
  EXCEPTION_NOTIFICATION_SETTINGS = [
    :email_prefix,
    :sender_address,
    :exception_recipients 
  ]
  
  VALID_SECTIONS = [
    :database_dumps_directory,
    :exception_notification
  ]
    
  def self.load_from_hash(config, hash)
    invalid_sections = hash.keys - VALID_SECTIONS
    raise "#{invalid_sections} are not valid sections" unless invalid_sections.empty?

    load_exception_notification(config, hash[:exception_notification])
    load_database_dumps_directory(hash[:database_dumps_directory])
  end
  
  def self.load_from_file(config, path)
    self.load_from_hash(config, symbolize_keys(YAML.load_file(path)))
  end
  
  def self.db_dumps_dir
    @@DB_DUMPS_DIR
  end
  
  private
  def self.symbolize_keys(hash)
    hash.inject({}) do |h, (k, v)|
      h[k.is_a?(String) ? k.to_sym : k] = (v.is_a?(Hash) ? symbolize_keys(v) : v)
      h
    end
  end
  
  def self.load_database_dumps_directory(path)
    if !path.nil?
      full_path = File.absolute_path(path)
      raise "Directory #{full_path} does not exist" unless Dir.exists?(full_path)
      @@DB_DUMPS_DIR = full_path
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