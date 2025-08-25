# Be sure to restart your server when you modify this file.
#
Rails.application.config.after_initialize do
  # STRINGS (not symbols)
  DISTRIBUTION_ASSERTABLE_TYPES = ApplicationRecord
    .descendants
    .select { |m|
       m.base_class.respond_to?(:is_distribution_assertable?) &&
       m.base_class.is_distribution_assertable?
    }.collect { |s| s.base_class.name }.uniq.freeze
end
