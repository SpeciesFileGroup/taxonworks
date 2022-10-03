
# Present = true; Absent = false (positive negative). Not provided -> no observation was made.
class Observation::PresenceAbsence < Observation
  validates :presence, inclusion: {in:  [true, false]}

  # TODO: this validation is technically not correct. The use case
  # is that citations exist for both a presence and and absence.
  # For example if the OTU is poorly defined, a fish at different stages, etc.
  #
  # We will have modify the UI when this is changed
  #
  # The true validation is that one true, and one false Observation are allowed.
  #
  validates_uniqueness_of :descriptor_id, scope: [:observation_object_id, :observation_object_type], message: 'the observation already exists'

  protected

end
