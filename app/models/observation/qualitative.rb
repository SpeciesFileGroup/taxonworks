#
#  See Descriptor::Qualitative
#
class Observation::Qualitative < Observation
  belongs_to :character_state

  validates_presence_of :character_state_id
  validate :unique_observation_object

  private

  def unique_observation_object
    if Observation::Qualitative.where(
        character_state_id: character_state_id,
        observation_object_id: observation_object_id,
        observation_object_type: observation_object_type,
        descriptor_id: descriptor_id
      ).where.not(id: id).exists?
      errors.add(:observation_object, 'the observation already exists')
    end
  end
end
