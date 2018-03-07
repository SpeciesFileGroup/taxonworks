# Be sure to restart your server when you modify this file.
DESCRIPTOR_TYPES = Descriptor.descendants.inject({}){|hsh,a| hsh.merge(a.name => a.human_name) }.freeze

