class Identifier::Global::Uuid::InaturalistIdentification < Identifier::Global::Uuid
  validate :object_is_taxon_determination

  private

  def object_is_taxon_determination
    errors.add(:identifier_object, 'must be a TaxonDetermination') unless identifier_object.is_a?(TaxonDetermination)
  end
end
