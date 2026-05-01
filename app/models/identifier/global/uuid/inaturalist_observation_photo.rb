class Identifier::Global::Uuid::InaturalistObservationPhoto < Identifier::Global::Uuid
  validate :object_is_image

  private

  def object_is_image
    errors.add(:identifier_object, 'must be an Image') unless identifier_object.is_a?(Image)
  end
end
