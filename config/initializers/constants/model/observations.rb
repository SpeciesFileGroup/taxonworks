# Be sure to restart your server when you modify this file.
OBSERVATION_TYPES = Observation.descendants.inject({}){|hsh,a| hsh.merge(a.name => a.human_name) }.freeze

