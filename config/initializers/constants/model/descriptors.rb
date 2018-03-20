# Be sure to restart your server when you modify this file.
#
Rails.application.config.after_initialize do 
  DESCRIPTOR_TYPES = Descriptor.descendants.inject({}){|hsh,a| hsh.merge(a.name => a.human_name) }.freeze
end

