class TaxonNameRelationship::Iczn::Invalidating::Homonym < TaxonNameRelationship::Iczn::Invalidating

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000289'

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_descendants_to_s(TaxonNameRelationship::Iczn::Invalidating::Usage) +
        self.collect_to_s(TaxonNameRelationship::Iczn::Invalidating,
            TaxonNameRelationship::Iczn::Invalidating::Synonym::Suppression::Total)

  end

#  def self.disjoint_object_classes
#    self.parent.disjoint_object_classes
#  end

  def subject_relationship_name
    'senior homonym'
  end

  def object_relationship_name
    'homonym'
  end

  def self.assignment_method
    # bus.set_as_iczn_homonym_of(aus)
    :iczn_set_as_homonym_of
  end

  # as.
  def self.inverse_assignment_method
    # aus.iczn_homonym = bus
    :iczn_homonym
  end

end
