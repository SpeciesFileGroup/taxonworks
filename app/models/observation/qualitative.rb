class Observation::Qualitative < Observation 
 
  belongs_to :character_state
  
  validates_presence_of :character_state_id
  #validate :character_state_is_unique
  validates_uniqueness_of :descriptor_id, scope: [:character_state_id, :observation_object_id, :observation_object_type], message: 'the observation already exists'

  protected
=begin
  def character_state_is_unique
    if Observation::Qualitative.object_scope(observation_object)
      .where(character_state_id: character_state_id, descriptor_id: descriptor_id).where.not(id: id).any?
      errors.add(:character_state_id, ' is already observed')
    end
  end
=end

end
