class TaxonNameRelationship::OriginalCombination::OriginalSubform < TaxonNameRelationship::OriginalCombination

  # left_side
  def self.valid_subject_ranks
    SPECIES_RANK_NAMES_ICN
  end

  # right_side
  def self.valid_object_ranks
    SPECIES_RANK_NAMES_ICN
  end

  def self.required_taxon_name_relationships
    self.collect_to_s(TaxonNameRelationship::OriginalCombination::OriginalSpecies,
                      TaxonNameRelationship::OriginalCombination::OriginalForm,
                      TaxonNameRelationship::OriginalCombination::OriginalGenus)
  end

  def self.assignment_method
    # bus.set_as_form_in_original_combination(aus)
    :subform_in_original_combination
  end

  #as
  def self.inverse_assignment_method
    # aus.original_form = bus
    :original_subform
  end

  def self.assignable
    true
  end

  def monominal_prefix
    'subf.'
  end

end
