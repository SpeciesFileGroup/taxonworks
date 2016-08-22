class Observation::Qualitative < Observation 
 
  belongs_to :character_state

  validates_presence_of :character_state_id
  validates_presence_of :frequency

  protected
 
end
