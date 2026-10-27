# Be sure to restart your server when you modify this file.
#
Rails.application.config.after_initialize do
  # STRINGS (not symbols)
  ENVIRONMENT_ASSERTABLE_TYPES = ApplicationRecord
    .descendants
    .select { |m|
       m.base_class.respond_to?(:is_environment_assertable?) &&
       m.base_class.is_environment_assertable?
    }.collect { |s| s.base_class.name }.uniq.freeze
end
