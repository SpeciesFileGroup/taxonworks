class TaxonNameRelationship::Iczn::Validating < TaxonNameRelationship::Iczn

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_descendants_and_itself_to_s(TaxonNameRelationship::Iczn::Invalidating)
  end

  def self.disjoint_subject_classes
    self.parent.disjoint_subject_classes +
        self.collect_descendants_and_itself_to_s(TaxonNameClassification::Iczn::Unavailable,
            TaxonNameClassification::Iczn::Available::Invalid)
  end

  def self.disjoint_object_classes
    self.parent.disjoint_object_classes +
        self.collect_descendants_and_itself_to_s(TaxonNameClassification::Iczn::Available::Valid) +
        self.collect_to_s(TaxonNameClassification::Iczn::Available::OfficialIndexOfAvailableNames,
            TaxonNameClassification::Iczn::Available::OfficialListOfAvailableNames,
            TaxonNameClassification::Iczn::Available::OfficialListOfWorksApprovedAsAvailable)

  end

  def self.subject_relationship_name
    'valid'
  end

  def self.object_relationship_name
    'invalid'
  end

end
