class TaxonNameRelationship::Iczn::Validating < TaxonNameRelationship::Iczn

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        TaxonNameRelationship::Iczn::Invalidating.descendants.collect{|t| t.to_s} +
        [TaxonNameRelationship::Iczn::Invalidating.to_s]
  end

  def self.disjoint_subject_classes
    self.parent.disjoint_subject_classes +
        TaxonNameClassification::Iczn::Unavailable.descendants.collect{|t| t.to_s} +
        [TaxonNameClassification::Iczn::Unavailable.to_s] +
        TaxonNameClassification::Iczn::Available::Invalid.descendants.collect{|t| t.to_s} +
        [TaxonNameClassification::Iczn::Available::Invalid.to_s]
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
