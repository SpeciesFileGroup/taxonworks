# Be sure to restart your server when you modify this file.
#
Rails.application.config.after_initialize do 
  OBSERVATION_TYPES = Observation.descendants.inject({}){|hsh,a| hsh.merge(a.name => a.human_name) }.freeze
  OBSERVABLE_TYPES = ApplicationRecord.descendants.select{|m| m.base_class.respond_to?(:is_observable?) && m.base_class.is_observable? }.collect{|s| s.base_class.name}.uniq.freeze
end
