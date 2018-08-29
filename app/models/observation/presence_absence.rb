
# Present = true; Absent = false (positive negative). Not provided -> no observation was made.
class Observation::PresenceAbsence < Observation
  validates :presence, inclusion: {in:  [true, false]}
end
