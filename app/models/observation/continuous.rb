class Observation::Continuous < Observation 

  validates :continuous_value, presence: true 

  protected
 
end
