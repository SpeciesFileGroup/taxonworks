class TaxonNameRelationship::Combination::Subform < TaxonNameRelationship::Combination

  # left_side
  def self.valid_subject_ranks
    SPECIES_RANK_NAMES_ICN
  end

  # right_side
  def self.valid_object_ranks
    SPECIES_RANK_NAMES_ICN
  end

  def self.required_taxon_name_relationships
    self.collect_to_s(TaxonNameRelationship::Combination::Species,
                      TaxonNameRelationship::Combination::Form,
                      TaxonNameRelationship::Combination::Genus)
  end

  def self.assignment_method
    :subform_in_combination
  end

  # as.
  def self.inverse_assignment_method
    :combination_subform
  end

  def self.assignable
    true
  end

end
