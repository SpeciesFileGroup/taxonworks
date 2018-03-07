# The Global Identifier that is used by collections for identification of an occurrence.
#
class Identifier::Global::OccurrenceId < Identifier::Global
  validate :using_occurrence_id_class

  def using_occurrence_id_class
    # todo: decide exactly what rules to use to qualify this class as acceptable.
  end
end
