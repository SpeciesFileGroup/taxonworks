# Be sure to restart your server when you modify this file.

# All assignable container types
CONTAINER_TYPES = Container.descendants

# All assignable container type names
CONTAINER_TYPE_NAMES = CONTAINER_TYPES.collect{|i| i.to_s}