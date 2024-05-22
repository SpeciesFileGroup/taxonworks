Rails.application.config.after_initialize do
  ::ActiveRecord.yaml_column_permitted_classes += [
    ::ActiveRecord::Type::Time::Value,
    ::ActiveSupport::TimeWithZone,
    ::ActiveSupport::TimeZone,
    ::BigDecimal,
    ::Date,
    ::Symbol,
    ::Time
  ]
end