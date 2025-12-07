# Be sure to restart your server when you modify this file.
#
Rails.application.config.after_initialize do
  # STRINGS (not symbols)
  CONTAINABLE_TYPES = ApplicationRecord
    .descendants
    .select { |m|
       m.base_class.respond_to?(:is_containable?) &&
       m.base_class.is_containable?
    }.collect { |s| s.base_class.name }.uniq.freeze
end
