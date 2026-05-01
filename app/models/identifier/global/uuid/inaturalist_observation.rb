class Identifier::Global::Uuid::InaturalistObservation < Identifier::Global::Uuid
  validate :object_is_field_occurrence

  private

  def object_is_field_occurrence
    errors.add(:identifier_object, 'must be a FieldOccurrence') unless identifier_object.is_a?(FieldOccurrence)
  end
end
