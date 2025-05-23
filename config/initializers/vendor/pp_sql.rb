if Rails.env.development? && defined?(Rails::Console)
  require 'pp_sql'
  PpSql.add_rails_logger_formatting = true
end