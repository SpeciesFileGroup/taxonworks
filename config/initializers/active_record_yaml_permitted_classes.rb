#This list comes from https://github.com/paper-trail-gem/paper_trail/blob/9a48fafb94b5b90020bd995d10415fb65c3944c0/doc/pt_13_yaml_safe_load.md
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