#   
# See Descriptor::Media
#
class Observation::Media < Observation

  validates_uniqueness_of :descriptor_id, scope: [:observation_object_id, :observation_object_type], message: 'the observation already exists'

  # TODO: Validate absence of everything
  # TODO: Validate presence of at least one Descriptor (use same logic as AssertedDistribution)
  
end
