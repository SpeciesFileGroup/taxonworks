class TaxonNameRelationship::Iczn::PotentiallyValidating < TaxonNameRelationship::Iczn

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000031'.freeze

  def self.disjoint_subject_classes
    self.parent.disjoint_subject_classes +
        self.collect_descendants_and_itself_to_s(TaxonNameClassification::Iczn::Unavailable) +
        [TaxonNameClassification::Iczn::Available::Invalid.to_s]
  end

  def self.disjoint_object_classes
    self.parent.disjoint_object_classes +
        self.collect_descendants_and_itself_to_s(TaxonNameClassification::Iczn::Available::Valid) +
        self.collect_to_s(TaxonNameClassification::Iczn::Available::OfficialListOfFamilyGroupNamesInZoology,
            TaxonNameClassification::Iczn::Available::OfficialListOfGenericNamesInZoology,
            TaxonNameClassification::Iczn::Available::OfficialListOfWorksApprovedAsAvailable)
  end

  def self.gbif_status_of_object
    'invalidum'
  end

  def subject_status_connector_to_object
    ' for'
  end
end
