# Be sure to restart your server when you modify this file.
#
Rails.application.config.after_initialize do
  # STRINGS (not symbols)
  BIOLOGICALLY_RELATABLE_TYPES = ApplicationRecord
    .descendants
    .select { |m|
       m.base_class.respond_to?(:is_biologically_relatable?) &&
       m.base_class.is_biologically_relatable?
    }.collect { |s| s.base_class.name }.uniq.freeze
end
