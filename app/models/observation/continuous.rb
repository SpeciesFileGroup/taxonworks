class Observation::Continuous < Observation

  validates_presence_of :continuous_value

  validates :continuous_unit, inclusion: { in: UNITS.keys,
    message: "'%{value}' is not a valid unit" }, allow_nil: true

  validate :units_compatible
  validates_uniqueness_of :descriptor_id, scope: [:continuous_value, :observation_object_id, :observation_object_type, :continuous_unit], message: 'the observation already exists'

  # @return [Unit]
  #  and instance of ruby-unit
  def unit
    ::RubyUnits::Unit.new(continuous_value.to_s + ' ' + continuous_unit)
  end

  # Use Ruby Units to add
  def +(observation)
    a = unit + observation.unit
    continuous_unit && descriptor.default_unit ? a.convert_to(descriptor.default_unit) : a
  end

  def -(observation)
    a = unit - observation.unit
    continuous_unit && descriptor.default_unit ? a.convert_to(descriptor.default_unit) : a
  end

  # @return [Float]
  #   return the value converted to the default of the descriptor If provided
  def converted_value
    if continuous_unit && descriptor.default_unit
      unit.convert_to(descriptor.default_unit).scalar.to_f # TODO: experiment with this
    elsif continuous_unit
      unit.scalar
    else
      continuous_value
    end
  end

  protected

  def units_compatible
    if descriptor && descriptor.default_unit && !continuous_unit.blank?
      # The =~ operator checks for convertability here.
      errors.add(:continuous_unit, 'units incompatible with descriptor default') unless unit =~ descriptor.unit
    end
  end

end
