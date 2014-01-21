class TaxonNameRelationship::Iczn::PotentiallyValidating < TaxonNameRelationship::Iczn

  def self.disjoint_subject_classes
    self.parent.disjoint_subject_classes + self.collect_descendants_and_itself_to_s(
        TaxonNameClassification::Iczn::Unavailable) + self.collect_to_s(
        TaxonNameClassification::Iczn::Available::Invalid)
  end

  def self.disjoint_object_classes
    self.parent.disjoint_object_classes +
        TaxonNameClassification::Iczn::Unavailable.descendants.collect{|t| t.to_s} +
        [TaxonNameClassification::Iczn::Unavailable.to_s] +
        [TaxonNameClassification::Iczn::Available::OfficialIndexOfAvailableNames.to_s] +
        [TaxonNameClassification::Iczn::Available::OfficialListOfAvailableNames.to_s] +
        [TaxonNameClassification::Iczn::Available::OfficialListOfWorksApprovedAsAvailable.to_s] +
        TaxonNameClassification::Iczn::Available::Valid.descendants.collect{|t| t.to_s}
  end

end
