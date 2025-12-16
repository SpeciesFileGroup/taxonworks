# A biological property like "male", "adult", "host", "parasite".
class BiologicalProperty < ControlledVocabularyTerm
  include Shared::BiologicalAssociationIndexHooks

  has_many :biological_relationship_types
  has_many :biological_relationships, through: :biological_relationship_types

  # @return [ActiveRecord::Relation]
  #   BiologicalAssociationIndex records for associations with relationships that use this property
  def biological_association_indices
    BiologicalAssociationIndex
      .joins('INNER JOIN biological_associations ba ON biological_association_indices.biological_association_id = ba.id')
      .joins('INNER JOIN biological_relationship_types brt ON brt.biological_relationship_id = ba.biological_relationship_id')
      .where('brt.biological_property_id = ?', id)
  end
end
