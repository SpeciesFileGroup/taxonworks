class TaxonNameRelationship::Iczn::Invalidating::Homonym::Primary < TaxonNameRelationship::Iczn::Invalidating::Homonym

  # left_side
  def self.valid_subject_ranks
    SPECIES_RANK_NAMES_ICZN
  end

  # right_side
  def self.valid_object_ranks
    SPECIES_RANK_NAMES_ICZN
  end


  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_descendants_and_itself_to_s(TaxonNameRelationship::Iczn::Invalidating::Homonym::Secondary) +
        self.collect_to_s(TaxonNameRelationship::Iczn::Invalidating::Homonym)
  end

  def self.subject_relationship_name
    'senior primary homonym'
  end

  def self.object_relationship_name
    'primary homonym'
  end

  def self.assignment_method
    # bus.set_as_iczn_primary_homonym_of(aus)
    :iczn_set_as_primary_homonym_of
  end

  def self.inverse_assignment_method
    # aus.iczn_primary_homonym = bus
    :iczn_primary_homonym
  end

end
