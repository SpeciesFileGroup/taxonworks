class TaxonNameRelationship::Combination::Subvariety < TaxonNameRelationship::Combination

  # left_side
  def self.valid_subject_ranks
    SPECIES_RANK_NAMES_ICN
  end

  # right_side
  def self.valid_object_ranks
    SPECIES_RANK_NAMES_ICN
  end

  def self.required_taxon_name_relationships
    self.collect_to_s(TaxonNameRelationship::Combination::Variety,
                      TaxonNameRelationship::Combination::Species,
                      TaxonNameRelationship::Combination::Genus)
  end

  def self.assignment_method
    :subvariety_in_combination
  end

  # as.
  def self.inverse_assignment_method
    :combination_subvariety
  end

  def self.assignable
    true
  end

end
