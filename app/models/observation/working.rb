#
# See Descriptor::Working
#
class Observation::Working < Observation
  validates_presence_of :description
  validates_uniqueness_of :descriptor_id, scope: [:observation_object_id, :observation_object_type]

end
