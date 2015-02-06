class TaxonNameRelationship::Iczn::Invalidating::Homonym::Secondary < TaxonNameRelationship::Iczn::Invalidating::Homonym

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000291'

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
        self.collect_to_s(TaxonNameRelationship::Iczn::Invalidating::Homonym,
            TaxonNameRelationship::Iczn::Invalidating::Homonym::Primary)
  end

  def self.subject_relationship_name
    'senior secondary homonym'
  end

  def self.object_relationship_name
    'secondary homonym'
  end

  def self.assignment_method
    # bus.set_as_iczn_secondary_homonym_of(aus)
    :iczn_set_as_secondary_homonym_of
  end

  def self.inverse_assignment_method
    # aus.iczn_secondary_homonym = bus
    :iczn_secondary_homonym
  end

end
