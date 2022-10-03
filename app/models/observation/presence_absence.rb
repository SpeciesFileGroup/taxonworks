
# Present = true; Absent = false (positive negative). Not provided -> no observation was made.
class Observation::PresenceAbsence < Observation
  validates :presence, inclusion: {in:  [true, false]}

  # !! Note that this allows one true, and one false value to be created.  The UI will have to be updated to reflect this. 
  validates_uniqueness_of :descriptor_id, scope: [:presence, :observation_object_id, :observation_object_type], message: 'the observation already exists'

  protected

end
