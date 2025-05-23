if Rails.env.development? && defined?(Rails::Console)
  require 'pp_sql'

  if ENV['TW_PP_SQL_CONSOLE_LOGGING']
    PpSql.add_rails_logger_formatting = true
  end

  def pp(bool)
    if bool == true || bool == false
      puts "PpSql logging is now set to #{bool}."
    else
      puts "Boolean input value required."
    end

    PpSql.add_rails_logger_formatting = bool
  end
end
