# Be sure to restart your server when you modify this file.
#
Rails.application.config.after_initialize do
  API_BUILDABLE_TYPES = Download.descendants.select{|m| m.respond_to?(:api_buildable?) && m.api_buildable? }.collect{|s| s.name}.uniq.freeze
end
