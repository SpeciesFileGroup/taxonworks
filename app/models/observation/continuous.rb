class Observation::Continuous < Observation

  validates_presence_of :continuous_value

  validates :continuous_unit, inclusion: { in: UNITS.keys,
    message: "'%{value}' is not a valid unit" }, allow_nil: true

end
