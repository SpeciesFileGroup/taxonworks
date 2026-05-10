class Identifier::Global::Uuid::InaturalistObservationSound < Identifier::Global::Uuid
  validate :object_is_sound

  private

  def object_is_sound
    errors.add(:identifier_object, 'must be a Sound') unless identifier_object.is_a?(Sound)
  end
end
