class TaxonNameRelationship::Iczn::Invalidating < TaxonNameRelationship::Iczn

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_descendants_and_itself_to_s(TaxonNameRelationship::Iczn::Validating)
  end

  def self.disjoint_subject_classes
    self.parent.disjoint_subject_classes +
        self.collect_descendants_to_s(TaxonNameClassification::Iczn::Available::Valid) +
        self.collect_to_s(TaxonNameClassification::Iczn::Available,
            TaxonNameClassification::Iczn::Available::OfficialIndexOfAvailableNames,
            TaxonNameClassification::Iczn::Available::OfficialListOfAvailableNames,
            TaxonNameClassification::Iczn::Available::OfficialListOfWorksApprovedAsAvailable)
  end

  def self.disjoint_object_classes
    self.parent.disjoint_object_classes + self.collect_descendants_to_s(
        TaxonNameClassification::Iczn::Unavailable)
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
