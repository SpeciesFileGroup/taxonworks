#
#  See Descriptor::Qualitative
#
class Observation::Qualitative < Observation 
  belongs_to :character_state
  
  validates_presence_of :character_state_id
  validates_uniqueness_of :character_state_id, scope: [:observation_object_id, :observation_object_type, :descriptor_id], message: 'the observation already exists'

end
