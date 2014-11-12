module Configuration
  
  EXCEPTION_NOTIFICATION_SETTINGS = [
    :email_prefix,
    :sender_address,
    :exception_recipients 
  ]
  
  VALID_SECTIONS = [
    :exception_notification
  ]
    
  def self.load_from_hash(config, hash)
    invalid_sections = hash.keys - VALID_SECTIONS
    raise "#{invalid_sections} are not valid sections" unless invalid_sections.empty?

    if hash[:exception_notification]
      settings = hash[:exception_notification]
      
      missing = EXCEPTION_NOTIFICATION_SETTINGS - settings.keys
      raise "Missing #{missing} settings in exception_notification" unless missing.empty?
      
      invalid = settings.keys - EXCEPTION_NOTIFICATION_SETTINGS
      raise "#{invalid} are not valid settings for exception_notification" unless invalid.empty?
      
      raise ":exception_recipients must be an Array" unless settings[:exception_recipients].class == Array
      
      config.middleware.use ExceptionNotification::Rack, email: settings
    end
    
  end
  
end