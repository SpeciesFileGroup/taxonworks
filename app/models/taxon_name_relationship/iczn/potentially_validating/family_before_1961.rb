class TaxonNameRelationship::Iczn::PotentiallyValidating::FamilyBefore1961 < TaxonNameRelationship::Iczn::PotentiallyValidating

  # left_side
  def self.valid_subject_ranks
    FAMILY_RANK_NAMES_ICZN
  end

  # right_side
  def self.valid_object_ranks
    FAMILY_RANK_NAMES_ICZN
  end

  def self.subject_relationship_name
    'family name based on genus synonym replaced before 1961'
  end

  def self.priority
    :direct
  end

  def self.assignment_method
    # Aidae.iczn_family_before_1961 = Bidae
    :iczn_family_before_1961
  end

  # as.
  def self.inverse_assignment_method
    # bus.set_as_iczn_family_before_1961_of(aus)
    :set_as_iczn_family_before_1961_of
  end

  def self.assignable
    true
  end

end