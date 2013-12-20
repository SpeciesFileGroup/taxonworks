class TaxonNameRelationship::Iczn::PotentiallyValidating < TaxonNameRelationship::Iczn

  def self.disjoint_subject_classes
    self.parent.disjoint_subject_classes +
        TaxonNameClass::Iczn::Unavailable.descendants.collect{|t| t.to_s} +
        [TaxonNameClass::Iczn::Available::Invalid.to_s]
  end

  def self.disjoint_object_classes
    self.parent.disjoint_object_classes +
        TaxonNameClass::Iczn::Unavailable.descendants.collect{|t| t.to_s} +
        [TaxonNameClass::Iczn::Available::OfficialIndexOfAvailableNames.to_s] +
        [TaxonNameClass::Iczn::Available::OfficialListOfAvailableNames.to_s] +
        [TaxonNameClass::Iczn::Available::OfficialListOfWorksApprovedAsAvailable.to_s] +
        TaxonNameClass::Iczn::Available::Valid.descendants.collect{|t| t.to_s}
  end

end
