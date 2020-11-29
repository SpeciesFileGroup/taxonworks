class TaxonNameRelationship::Iczn::Validating < TaxonNameRelationship::Iczn

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000264'.freeze

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
    self.parent.disjoint_object_classes
  end

  def subject_status_connector_to_object
    ' for'
  end

  def object_status
    'valid'
  end

  def subject_status
    'invalid'
  end

  def self.gbif_status_of_subject
    'valid'
  end

  def self.gbif_status_of_object
    'invalidum'
  end

end
