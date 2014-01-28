class TaxonNameRelationship::Combination::Subsection < TaxonNameRelationship::Combination

  #left_side
  def self.valid_subject_ranks
    GENUS_RANK_NAMES_ICN
  end

  # right_side
  def self.valid_object_ranks
    GENUS_AND_SPECIES_RANK_NAMES_ICN
  end

  def self.required_taxon_name_relationships
    self.collect_to_s(TaxonNameRelationship::Combination::Genus,
                      TaxonNameRelationship::Combination::Section)
  end

  def self.assignment_method
    :subsection_in_combination
  end

  # as.
  def self.inverse_assignment_method
    :combination_section
  end

  def self.assignable
    true
  end

end
