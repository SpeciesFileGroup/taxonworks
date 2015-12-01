class TaxonNameRelationship::Iczn::Validating < TaxonNameRelationship::Iczn

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000264'

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

  def subject_relationship_name
    'valid'
  end

  def object_relationship_name
    'invalid'
  end

  def self.gbif_status_of_subject
    'valid'
  end

  def self.gbif_status_of_object
    'invalidum'
  end

end
