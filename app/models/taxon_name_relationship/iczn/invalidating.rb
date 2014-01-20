class TaxonNameRelationship::Iczn::Invalidating < TaxonNameRelationship::Iczn

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        TaxonNameRelationship::Iczn::Validating.descendants.collect{|t| t.to_s} +
        [TaxonNameRelationship::Iczn::Validating.to_s]
  end

  def self.disjoint_subject_classes
    self.parent.disjoint_subject_classes +
        TaxonNameClassification::Iczn::Available::Valid.descendants.collect{|t| t.to_s} +
        [TaxonNameClassification::Iczn::Available.to_s] +
        [TaxonNameClassification::Iczn::Available::OfficialIndexOfAvailableNames.to_s] +
        [TaxonNameClassification::Iczn::Available::OfficialListOfAvailableNames.to_s] +
        [TaxonNameClassification::Iczn::Available::OfficialListOfWorksApprovedAsAvailable.to_s]
  end

  def self.disjoint_object_classes
    self.parent.disjoint_object_classes +
        TaxonNameClassification::Iczn::Unavailable.descendants.collect{|t| t.to_s}
  end

  def self.nomenclatural_priority
    :direct
  end

  def self.assignable
    true
  end

  def self.assignment_method
    # aus.iczn_invalid = bus   ## Equal to synonym in broad sense
    :iczn_invalid
  end

  # as.
  def self.inverse_assignment_method
    # bus.set_as_iczn_invalid_of(aus)
    :set_as_iczn_invalid_of
  end

  def self.subject_relationship_name
    'invalid name'
  end

  def self.object_relationship_name
    'valid name'
  end



end
