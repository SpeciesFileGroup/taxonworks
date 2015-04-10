class TaxonNameRelationship::Combination::Variety < TaxonNameRelationship::Combination

  # left_side
  def self.valid_subject_ranks
    SPECIES_RANK_NAMES
  end

  # right_side
  def self.valid_object_ranks
    SPECIES_RANK_NAMES
  end

  def self.required_taxon_name_relationships
    self.collect_to_s(TaxonNameRelationship::Combination::Genus,
                      TaxonNameRelationship::Combination::Species)
  end

  def self.assignment_method
    :variety_in_combination
  end

  # as.
  def self.inverse_assignment_method
    :combination_variety
  end

  def self.assignable
    true
  end

end
