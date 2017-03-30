class Descriptor::Continuous < Descriptor

  has_many :observations, -> { where(observations: {type: 'Observation::Continuous'}) }, foreign_key: :descriptor_id

end