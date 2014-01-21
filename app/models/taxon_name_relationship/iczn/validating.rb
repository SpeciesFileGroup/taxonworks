class TaxonNameRelationship::Iczn::Validating < TaxonNameRelationship::Iczn

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships + self.collect_descendants_and_itself_to_s(
        TaxonNameRelationship::Iczn::Invalidating)
  end

  def self.disjoint_subject_classes
    self.parent.disjoint_subject_classes + self.collect_descendants_and_itself(
        TaxonNameClassification::Iczn::Unavailable,
        TaxonNameClassification::Iczn::Available::Invalid)
  end

  def self.disjoint_object_classes
    self.parent.disjoint_object_classes +
        TaxonNameClassification::Iczn::Unavailable.descendants.collect{|t| t.to_s} +
        [TaxonNameClassification::Iczn::Available::OfficialIndexOfAvailableNames.to_s] +
        [TaxonNameClassification::Iczn::Available::OfficialListOfAvailableNames.to_s] +
        [TaxonNameClassification::Iczn::Available::OfficialListOfWorksApprovedAsAvailable.to_s] +
        TaxonNameClassification::Iczn::Available::Valid.descendants.collect{|t| t.to_s}
  end

  def self.subject_relationship_name
    'valid name'
  end

  def self.subject_relationship_name
    'invalid name'
  end

end
