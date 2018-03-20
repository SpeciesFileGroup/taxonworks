# Be sure to restart your server when you modify this file.
#
Rails.application.config.after_initialize do 
  CONTAINER_TYPES = Container.descendants.map(&:name).freeze
end

