class Descriptor::PresenceAbsence < Descriptor

  has_many :observations, -> { where(observations: {type: 'Observation::PresenceAbsence'}) }, foreign_key: :descriptor_id

end