class TaxonNameRelationship::Iczn::Invalidating::Homonym::Primary < TaxonNameRelationship::Iczn::Invalidating::Homonym

  # left_side
  def self.valid_subject_ranks
    NomenclaturalRank::Iczn::SpeciesGroup.descendants.collect{|t| t.to_s}
  end

  # right_side
  def self.valid_object_ranks
    NomenclaturalRank::Iczn::SpeciesGroup.descendants.collect{|t| t.to_s}
  end

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        TaxonNameRelationship::Iczn::Invalidating::Homonym::Secondary.descendants.collect{|t| t.to_s} +
        [TaxonNameRelationship::Iczn::Invalidating::Homonym::Secondary.to_s] +
        [TaxonNameRelationship::Iczn::Invalidating::Homonym.to_s]
  end

  def self.subject_relationship_name
    'primary homonym'
  end

  def self.object_relationship_name
    'senior primary homonym'
  end

  def self.assignment_method
    # aus.iczn_primary_homonym = bus
    :iczn_primary_homonym
  end

  # as.
  def self.inverse_assignment_method
    # bus.set_as_iczn_primary_homonym_of(aus)
    :set_as_iczn_primary_homonym_of
  end

end
