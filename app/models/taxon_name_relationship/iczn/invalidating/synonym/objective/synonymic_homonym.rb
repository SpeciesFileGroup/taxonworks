class TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective::SynonymicHomonym < TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        [TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective.to_s] +
        [TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective::UnjustifiedEmendation.to_s] +
        [TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective::UnnecessaryReplacementName.to_s]
  end

  def self.subject_relationship_name
    'synonymic homonym'
  end

  def self.object_relationship_name
    'senior synonymic homonym'
  end

  def self.assignment_method
    # aus.iczn_synonymic_homonym = bus
    :iczn_synonymic_homonym
  end

  # as.
  def self.inverse_assignment_method
    # bus.set_as_iczn_synonymic_homonym_of(aus)
    :set_as_iczn_synonymic_homonym
  end

end
