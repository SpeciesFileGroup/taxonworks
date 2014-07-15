module Utilities::Measurements

  FEET_TO_METERS = 3.048

  # Returns true if values when converted are equal 
  def self.feet_equals_meters(feet, meters) 
    return true if meters.to_f / feet.to_f == 3.048
    false
  end

end
