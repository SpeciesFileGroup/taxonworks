class TaxonNameRelationship::Iczn::PotentiallyValidating < TaxonNameRelationship::Iczn

  def self.disjoint_subject_classes
    self.parent.disjoint_subject_classes + self.collect_descendants_and_itself_to_s(
        TaxonNameClassification::Iczn::Unavailable) + self.collect_to_s(
        TaxonNameClassification::Iczn::Available::Invalid)
  end

  def self.disjoint_object_classes
    self.parent.disjoint_object_classes + self.collect_descentants_and_itself_to_s(
        TaxonNameClassification::Iczn::Unavailable) + self.collect_descentants_to_s(
        TaxonNameClassification::Iczn::Available::Valid) + self.collect_to_s(
        TaxonNameClassification::Iczn::Available::OfficialIndexOfAvailableNames,
        TaxonNameClassification::Iczn::Available::OfficialListOfAvailableNames,
        TaxonNameClassification::Iczn::Available::OfficialListOfWorksApprovedAsAvailable)
  end

end
