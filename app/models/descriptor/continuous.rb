class Descriptor::Continuous < Descriptor
  has_many :observations, -> { where(observations: {type: 'Observation::Continuous'}) }, foreign_key: :descriptor_id

  validates :default_unit, inclusion: { in: UNITS.keys,
    message: "%{value} is not a valid unit" }, allow_nil: true

end
