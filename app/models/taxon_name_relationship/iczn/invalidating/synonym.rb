class TaxonNameRelationship::Iczn::Invalidating::Synonym < TaxonNameRelationship::Iczn::Invalidating

  validates_uniqueness_of :subject_taxon_name_id

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        TaxonNameRelationship::Iczn::Invalidating::Usage.descendants.collect{|t| t.to_s} +
        TaxonNameRelationship::Iczn::Invalidating::Homonym.descendants.collect{|t| t.to_s} +
        [TaxonNameRelationship::Iczn::Invalidating::Homonym.to_s] +
        [TaxonNameRelationship::Iczn::Invalidating.to_s]
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