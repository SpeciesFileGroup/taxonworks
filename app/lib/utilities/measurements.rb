module Utilities::Measurements

  FEET_TO_METERS = 3.048

  # Returns true if values when converted are equal
  # @param [Float] feet
  # @param [Float] meters
  # @return [Boolean]
  # TODO: check to see if the ratio will *always* be _exactly_ 3.048.
  def self.feet_equals_meters(feet, meters)
    return true if meters.to_f / feet.to_f == 3.048
    false
  end

end
