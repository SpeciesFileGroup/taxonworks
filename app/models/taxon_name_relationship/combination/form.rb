class TaxonNameRelationship::Combination::Form < TaxonNameRelationship::Combination

  # left_side
  def self.valid_subject_ranks
    SPECIES_RANK_NAMES
  end

  # right_side
  def self.valid_object_ranks
    SPECIES_RANK_NAMES
  end

  def self.required_taxon_name_relationships
    self.collect_to_s(TaxonNameRelationship::Combination::Species,
                      TaxonNameRelationship::Combination::Genus)
  end

  def self.assignment_method
    :form_in_combination
  end

  # as.
  def self.inverse_assignment_method
    :combination_form
  end

  def self.assignable
    true
  end

end
