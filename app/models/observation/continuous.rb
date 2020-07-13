class Observation::Continuous < Observation

  validates_presence_of :continuous_value

  validates :continuous_unit, inclusion: { in: UNITS.keys,
    message: "'%{value}' is not a valid unit" }, allow_nil: true

  validate :units_compatible

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

  protected

  def units_compatible
    if descriptor && descriptor.default_unit && !continuous_unit.blank?
      errors.add(:continuous_unit, 'units incompatible with descriptor default') unless unit =~ descriptor.unit
    end
  end

end
