class TaxonNameRelationship::Iczn::Invalidating::Synonym::FamilyBefore1961 < TaxonNameRelationship::Iczn::Invalidating::Synonym

  # left_side
  def self.valid_subject_ranks
    FAMILY_RANK_NAMES_ICZN
  end

  # right_side
  def self.valid_object_ranks
    FAMILY_RANK_NAMES_ICZN
  end

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective.descendants.collect{|t| t.to_s} +
        [TaxonNameRelationship::Iczn::Invalidating::Synonym.to_s] +
        [TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective.to_s] +
        [TaxonNameRelationship::Iczn::Invalidating::Synonym::ForgottenName.to_s] +
        [TaxonNameRelationship::Iczn::Invalidating::Synonym::Subjective.to_s] +
        [TaxonNameRelationship::Iczn::Invalidating::Synonym::Suppression.to_s]
  end

  def self.subject_relationship_name
    'family name based on genus synonym replaced before 1961'
  end

  def self.assignment_method
    # aus.iczn_family_before_1961 = bus
    :iczn_family_before_1961
  end

  # as.
  def self.inverse_assignment_method
    # bus.set_as_iczn_family_before_1961_of(aus)
    :set_as_iczn_family_before_1961_of
  end

end