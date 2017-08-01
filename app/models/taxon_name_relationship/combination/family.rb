class TaxonNameRelationship::Combination::Family < TaxonNameRelationship::Combination

  #left_side
  def self.valid_subject_ranks
    FAMILY_AND_ABOVE_RANK_NAMES
  end

  # right_side
  def self.valid_object_ranks
    FAMILY_AND_ABOVE_RANK_NAMES
  end

  def self.assignment_method
    :family_in_combination
  end

  # as.
  def self.inverse_assignment_method
    :combination_family
  end

  def self.assignable
    true
  end

end
