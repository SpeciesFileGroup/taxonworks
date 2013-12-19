class TaxonNameRelationship::Iczn::Invalidating::Homonym < TaxonNameRelationship::Iczn::Invalidating

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        TaxonNameRelationship::Iczn::Invalidating::Synonym.descendants.collect{|t| t.to_s} +
        [TaxonNameRelationship::Iczn::Invalidating::Synonym.to_s] +
        TaxonNameRelationship::Iczn::Invalidating::Usage.descendants.collect{|t| t.to_s}
        [TaxonNameRelationship::Iczn::Invalidating.to_s]
  end

  def self.disjoint_object_classes
    self.parent.disjoint_object_classes +
        TaxonNameClass::Iczn::Unavailable.descendants.collect{|t| t.to_s} +
        [TaxonNameClass::Iczn::Available::Invalid.to_s]
  end

  def self.assignment_method
    # aus.iczn_homonym = bus
    :iczn_homonym
  end

  # as.
  def self.inverse_assignment_method
    # bus.set_as_iczn_homonym_of(aus)
    :set_as_iczn_homonym_of
  end

end
