class Observation::Qualitative < Observation 
 
  belongs_to :character_state
  
  validates_presence_of :character_state
  validate :character_state_is_unique

  protected

  def character_state_is_unique
    if Observation::Qualitative.object_scope(observation_object).where(character_state_id: character_state_id, descriptor_id: descriptor_id).any?
      errors.add(:character_state_id, ' is already observed')
    end
  end

end
