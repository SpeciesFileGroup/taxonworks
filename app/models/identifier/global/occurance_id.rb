# The Global Identifier that is used by collections for identification of an occurrence.
#
class Identifier::Global::OccurrenceId < Identifier::Global
  validate :using_occurrence_id_class

  def using_occurrence_id_class
    if identifier.blank?
      errors.add(:identifier, "can't be blank.")
      retval = false
    else
      retval = true
    end
    retval
  end
end
