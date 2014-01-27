class TaxonNameRelationship::Iczn::Validating::UncertainPlacement < TaxonNameRelationship::Iczn::Validating

  # left_side
  def self.valid_subject_ranks
    GENUS_AND_SPECIES_RANK_NAMES_ICZN
  end

  # right_side
  def self.valid_object_ranks
    FAMILY_RANK_NAMES_ICZN
  end

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_to_s(TaxonNameRelationship::Iczn::Validating::ConservedName,
            TaxonNameRelationship::Iczn::Validating::ConservedWork)
  end

  def self.assignable
    true
  end

  def self.assignment_method
    # aus.iczn_uncertain_placement = Family
    :iczn_uncertain_placement
  end

  def self.object_relationship_name
    'incertae sedis'
  end

end
