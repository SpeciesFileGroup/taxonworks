class TaxonNameRelationship::Iczn::Invalidating::Synonym < TaxonNameRelationship::Iczn::Invalidating

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_descendants_to_s(TaxonNameRelationship::Iczn::Invalidating::Usage) +
            [TaxonNameRelationship::Iczn::Invalidating.to_s]
  end

  def self.disjoint_object_classes
    self.parent.disjoint_object_classes +
        self.collect_descendants_and_itself_to_s(TaxonNameClassification::Iczn::Available::Invalid)
  end

  def self.subject_relationship_name
    'synonym'
  end

  def self.object_relationship_name
    'senior synonym'
  end


  def self.assignment_method
         # aus.iczn_synonym = bus
    :iczn_synonym
  end

  # as.
  def self.inverse_assignment_method
    # bus.set_as_iczn_synonym_of(aus)
    :set_as_iczn_synonym_of
  end

end